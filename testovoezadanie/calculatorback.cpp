#include "calculatorback.h"

CalculatorBack::CalculatorBack(QObject *parent)
    : QObject(parent), is_stopped(false), use_lib(false), sleep_time(5){

    worker_thread = std::thread(&CalculatorBack::processNumbers, this);

    connect(this, &CalculatorBack::queueResultsChanged, this, &CalculatorBack::paintExp);
}


CalculatorBack::~CalculatorBack() {

    is_stopped = true;

    if (worker_thread.joinable()) {
        worker_thread.join();
    }
}


void CalculatorBack::addHistory(const QString &note, const QString &color){

    QVariantMap item;
    item["note"] = note;
    item["color"] = color;

    history.prepend(item);

    emit historyUpd();
}


void CalculatorBack::addExp(const QString &expression){

    QString exp = expression;
    makeClearExpression(exp);

    addHistory(exp, "green");

    QueueRequests.enqueue(std::move(exp));
    emit QueueRequestsUpd();
}


void CalculatorBack::paintExp(){

    if(auto elem = QueueResults.dequeue()){

        addHistory((*elem).first, (*elem).second ? "red" : "blue");
    }
}


void CalculatorBack::parseExpression(const QString &expression, int &TypeWork, double &a, double &b) const{

    int index = expression.indexOf(QRegExp("[+\\-*÷]"), 1);

    if (index == -1){

        TypeWork = 4;
        a = expression.toDouble();
        return;
    }

    a = expression.leftRef(index).toDouble();
    b = expression.midRef(index + 1).toDouble();
    QChar operation = expression[index];

    if (operation == "+"){
        TypeWork = 0;
    }
    else if (operation == "-"){
        TypeWork = 1;
    }
    else if (operation == "*"){
        TypeWork = 2;
    }
    else if (operation == "÷"){
        TypeWork = 3;
    }
}


double CalculatorBack::DoIt(int TypeWork, double OperandA, double OperandB) const{

    switch (TypeWork){

        case 0:
            return OperandA + OperandB;

        case 1:
            return OperandA - OperandB;

        case 2:
            return OperandA * OperandB;

        case 3:
            if (OperandB == 0.0)
                throw std::logic_error("divide by zero");
            return OperandA / OperandB;

        case 4:
            return OperandA;

        default:
            throw std::logic_error("unknown operation");
    }
}


void CalculatorBack::processNumbers() {

    while (!is_stopped) {

        if(auto elem = QueueRequests.dequeue()){

            emit QueueRequestsUpd();

            std::this_thread::sleep_for(std::chrono::seconds(sleep_time));

            int TypeWork = -1;
            double OperandA = 0.0, OperandB = 0.0;

            parseExpression(*elem, TypeWork, OperandA, OperandB);

            try{

                if (use_lib){

                    QueueResults.enqueue(std::make_pair(*elem + " = " +
                                         QString::number(LIBTESTZADANIE::DoIt(TypeWork, OperandA, OperandB)), false));
                    qDebug() << "LIB";
                }
                else{

                    QueueResults.enqueue(std::make_pair(*elem + " = " +
                                         QString::number(DoIt(TypeWork, OperandA, OperandB)), false));
                    qDebug() << "CLASS";
                }

            } catch (std::logic_error &err){

                QueueResults.enqueue(std::make_pair(*elem + ": " + err.what(), true));
            }

            emit queueResultsChanged();
        }
    }
}


size_t CalculatorBack::getQueueRequestsSize() const
{
    return QueueRequests.size();
}


void CalculatorBack::clearHistory()
{
    history.clear();
    emit historyUpd();
}


void CalculatorBack::makeClearExpression(QString &expression) const
{
    int index = expression.indexOf(QRegExp("[+\\-*÷]"), 1);
    if (index == -1){

        return;
    }
    else if (index == expression.length() - 1){

        double a = expression.leftRef(index).toDouble();
        expression = QString::number(a) + expression[index] + QString::number(a);
    }
    else{

        double a = expression.leftRef(index).toDouble();
        double b = expression.midRef(index + 1).toDouble();
        expression = QString::number(a) + expression[index] + QString::number(b);
    }
}


void CalculatorBack::setSleepTime(int value)
{
    sleep_time = value;
}


void CalculatorBack::setUseLib(bool value)
{
    use_lib = value;
}

