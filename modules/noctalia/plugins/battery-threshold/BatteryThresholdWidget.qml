import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0
  property var pluginApi

  property bool conservationEnabled: false
  property bool busy: false
  property string lastError: ""

  readonly property var pluginSettings: pluginApi ? pluginApi.pluginSettings || {} : {}
  readonly property string sysfsPath: pluginSettings.sysfsPath || ""
  readonly property string conservationUnit: pluginSettings.conservationUnit || "battery-threshold-mode@conservation.service"
  readonly property string normalUnit: pluginSettings.normalUnit || "battery-threshold-mode@normal.service"
  readonly property int pollIntervalMs: pluginSettings.pollIntervalMs || 10000

  function refreshState() {
    if (!sysfsPath || readProcess.running) {
      return;
    }

    readProcess.command = ["cat", sysfsPath];
    readProcess.running = true;
  }

  function toggleMode() {
    if (!sysfsPath || busy || toggleProcess.running) {
      return;
    }

    busy = true;
    lastError = "";
    toggleProcess.command = ["systemctl", "start", conservationEnabled ? normalUnit : conservationUnit];
    toggleProcess.running = true;
  }

  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  applyUiScale: false
  customRadius: Style.radiusL
  visible: sysfsPath !== ""
  icon: conservationEnabled ? "battery-eco" : "battery"
  tooltipText: lastError !== ""
    ? `Battery threshold toggle failed: ${lastError}`
    : (conservationEnabled
      ? "Battery conservation mode enabled"
      : "Battery conservation mode disabled")
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  colorBg: conservationEnabled ? Color.mPrimary : Style.capsuleColor
  colorFg: conservationEnabled ? Color.mOnPrimary : Color.mOnSurface
  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth
  onClicked: toggleMode()

  Component.onCompleted: refreshState()

  Timer {
    interval: root.pollIntervalMs
    repeat: true
    running: root.visible
    onTriggered: root.refreshState()
  }

  Process {
    id: readProcess

    running: false
    stdout: StdioCollector {
      id: readStdout
    }

    onExited: function(exitCode) {
      if (exitCode !== 0) {
        return;
      }

      root.conservationEnabled = (readStdout.text || "").trim() === "1";
    }
  }

  Process {
    id: toggleProcess

    running: false
    stderr: StdioCollector {
      id: toggleStderr
    }

    onExited: function(exitCode) {
      root.busy = false;

      if (exitCode !== 0) {
        root.lastError = (toggleStderr.text || "").trim() || "unknown error";
        ToastService.showError("Battery Threshold", root.lastError);
        return;
      }

      root.refreshState();
    }
  }
}
