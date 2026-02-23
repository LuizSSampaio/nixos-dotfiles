import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 24

    Text {
        anchors.centerIn: parent

        text: "hello world"
    }
}
