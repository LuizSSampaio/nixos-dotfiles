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
    color: Colors.base00

    Text {
        anchors.centerIn: parent

        text: "hello world"
        color: Colors.base05
    }
}
