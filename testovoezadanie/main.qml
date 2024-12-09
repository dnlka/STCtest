import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0


ApplicationWindow {
    visible: true
    minimumWidth: 700
    minimumHeight: 400
    title: "Калькулятор"
    width: windowSettings.windowWidth
    height: windowSettings.windowHeight
    x: windowSettings.windowX
    y: windowSettings.windowY

    onClosing: {
        windowSettings.windowWidth = width
        windowSettings.windowHeight = height
        windowSettings.windowX = x
        windowSettings.windowY = y
    }

    Settings {
        id: windowSettings
        property int windowWidth: 700
        property int windowHeight: 400
        property int windowX: 100
        property int windowY: 100
    }

    Rectangle {
        id: rect_id
        anchors.fill: parent
        color: "#F0F0F0"
        focus: true
        Keys.onPressed: {
            if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                repeater_id.itemAt(event.key - 48).released();
            }
            else if (event.key === Qt.Key_Plus){
                repeater_signs_id.itemAt(3).released();
            }
            else if (event.key === Qt.Key_Minus){
                repeater_signs_id.itemAt(2).released();
            }
            else if (event.key === Qt.Key_Asterisk){
                repeater_signs_id.itemAt(1).released();
            }
            else if (event.key === Qt.Key_Slash){
                repeater_signs_id.itemAt(0).released();
            }
            else if (event.key === Qt.Key_Period){
                dot_btn.released();
            }
            else if (event.key === Qt.Key_Backspace){
                bs_btn.released();
            }
            else if (event.key === Qt.Key_Equal || event.key === Qt.Key_Enter){
                eq_btn.released();
            }
        }


        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 1

                Label {
                    text: "Размер очереди:" + calculator.queue_size
                    font.pixelSize: 14
                }

                RowLayout {
                    Label {
                        text: "Время вычисления:"
                        font.pixelSize: 14
                    }

                    SpinBox {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 30
                        value: 5
                        onValueChanged: calculator.setSleepTime(value)
                    }

                    CheckBox {
                        text: "Функция библиотеки"
                        checked: false
                        onClicked: {
                            calculator.setUseLib(checked)
                        }
                    }
                }


                //ввод
                TextInput {
                    id: tf_id
                    anchors.right: parent.right
                    text: "0"
                    font.pixelSize: 24
                    readOnly: true
                    property int maxLength: 33
                    onTextChanged: {
                        if (text.length > maxLength) {
                            text = text.slice(0, maxLength);
                        }
                    }

                }

                GridLayout {
                    id: gl_id
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: tf_id.bottom
                    anchors.topMargin: 20
                    rowSpacing: 10
                    columnSpacing: 10
                    columns: 4

                    //цифры
                    Repeater {
                        id: repeater_id
                        model: 10
                        Button {
                            text: index.toString()
                            Layout.row: index === 0 ? 4 : 3 - Math.floor((index - 1) / 3)
                            Layout.column: index === 0 ? 1 : (index - 1) % 3
                            width: 60
                            height: 60
                            onReleased: tf_id.text = tf_id.text === "0" ? text : tf_id.text + text
                        }
                    }

                    //точка
                    Button {
                        id: dot_btn
                        text: "."
                        Layout.row: 4
                        Layout.column: 2
                        width: 60
                        height: 60
                        onReleased: {
                            var currentText = tf_id.text;
                            var lastNumber = currentText.split(/[\+\-\*\÷]/).pop();
                            var lastChar = currentText.slice(-1);
                            if (!lastNumber.includes(".") && !["+", "-", "*", "÷"].includes(lastChar)){

                                tf_id.text += text;
                            }
                        }
                    }

                    //знак
                    Button {
                        id: sign_btn
                        text: "+/-"
                        Layout.row: 4
                        Layout.column: 0
                        width: 60
                        height: 60
                        onReleased: {
                            if (tf_id.text !== "0") {
                                if (tf_id.text.startsWith("-")) {
                                    tf_id.text = tf_id.text.slice(1);
                                } else {
                                    tf_id.text = "-" + tf_id.text;
                                }
                            }
                        }
                    }

                    //сброс
                    Button {
                        text: "C"
                        Layout.row: 0
                        Layout.column: 0
                        Layout.columnSpan: 2
                        width: 130
                        height: 60
                        onReleased: tf_id.text = "0"
                    }

                    //бекспейс
                    Button {
                        id: bs_btn
                        text: "⌫"
                        Layout.row: 0
                        Layout.column: 2
                        Layout.columnSpan: 2
                        width: 130
                        height: 60
                        onReleased: tf_id.text = tf_id.text.length > 1 ? tf_id.text.slice(0, -1) : "0"
                    }

                    //операции
                    Repeater {
                        id: repeater_signs_id
                        model: ["÷", "*", "-", "+"]
                        Button {
                            text: modelData
                            Layout.row: index
                            Layout.column: 3
                            width: 60
                            height: 60
                            onReleased: {
                                let containsOperation = repeater_signs_id.model.some(op => tf_id.text.slice(1).includes(op));
                                if (!containsOperation) {
                                    tf_id.text += text;
                                }
                                else{
                                    let endsWithOperation = repeater_signs_id.model.some(op => tf_id.text.endsWith(op));
                                    if (endsWithOperation) tf_id.text = tf_id.text.slice(0, -1) + text;
                                }
                            }
                        }
                    }

                    //равно
                    Button {
                        id: eq_btn
                        text: "="
                        Layout.row: 4
                        Layout.column: 3
                        width: 60
                        height: 60
                        onReleased: {
                            calculator.addExp(tf_id.text);
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 1

                Rectangle {
                    width: 200
                    Layout.fillHeight: true
                    color: "#f8f8f8"
                    border.color: "#ccc"

                    //история
                    ListView {
                        id: historyView
                        width: parent.width
                        height: parent.height
                        model: calculator.history_qml

                        delegate: Item {
                            width: parent.width
                            height: 30
                            Rectangle {
                                width: parent.width
                                height: 30
                                color: index % 2 === 0 ? "#e0e0e0" : "#ffffff"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.note || "No note"
                                    font.pixelSize: 15
                                    color: modelData.color || "black"
                                }
                            }
                        }
                    }
                }
                //чистка истории
                Button {
                    text: "Очистить"
                    width: 60
                    height: 60
                    anchors.horizontalCenter: parent.horizontalCenter
                    onReleased: {
                        calculator.clearHistory();
                    }
                }
            }
        }
    }
}

