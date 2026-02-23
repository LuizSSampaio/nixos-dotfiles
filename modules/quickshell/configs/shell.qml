import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: bar

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 24
            color: Colors.base00

            WlrLayershell.namespace: "quickshell:bar"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 0

                Item {
                    Layout.fillWidth: true
                }

                Clock {}

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
            }
        }
    }
}
