#ifndef CALCULATORBACK_H
#define CALCULATORBACK_H

#include <QObject>
#include <QDebug>
#include <thread>
#include <queue>
#include <atomic>

#include "threadsafequeue.h"
#include "libtestzadanie.h"


class CalculatorBack : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList history_qml MEMBER history NOTIFY historyUpd())
    Q_PROPERTY(int queue_size READ getQueueRequestsSize NOTIFY QueueRequestsUpd())

public:
    explicit CalculatorBack(QObject *parent = nullptr);

    ~CalculatorBack() override;

    size_t getQueueRequestsSize() const;

public slots:
    void addExp(const QString &expression);

    void paintExp();

    void setUseLib(bool value);

    void setSleepTime(int value);

    void clearHistory();

signals:
    void queueResultsChanged();

    void historyUpd();

    void QueueRequestsUpd();

private:
    void makeClearExpression(QString &expression) const;

    void addHistory(const QString &note, const QString &color);

    void parseExpression(const QString &expression, int &TypeWork, double &a, double &b) const;

    double DoIt (int TypeWork, double OperandA, double OperandB) const;

    void processNumbers();

    ThreadSafeQueue<QString> QueueRequests;
    ThreadSafeQueue<std::pair<QString, bool>> QueueResults; //true РєСЂР°СЃРЅС‹Р№ false СЃРёРЅРёР№
    QVariantList history;
    std::thread worker_thread;
    std::atomic_bool is_stopped;
    std::atomic_bool use_lib;
    std::atomic_int sleep_time;
};

#endif // CALCULATORBACK_H
