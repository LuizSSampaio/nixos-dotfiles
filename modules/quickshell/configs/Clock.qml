import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: clockText.implicitWidth + 24
    implicitHeight: parent.height

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: clockText
        anchors.centerIn: parent

        text: Qt.formatDateTime(clock.date, "ddd HH:mm")
        color: Colors.base05
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 12
        font.bold: true
    }
}
