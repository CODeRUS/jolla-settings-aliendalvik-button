import QtQuick 2.1
import Sailfish.Silica 1.0
import org.nemomobile.dbus 2.0
import com.jolla.apkd 1.0
import com.jolla.settings 1.0
import com.jolla.settings.system 1.0

SettingsToggle {
    id: root
    property string entryPath

    property bool alienDalvikRunning
    property bool alienDalvikAutostart
    property bool ready

    DBusInterface {
        id: apkInterface

        bus: DBus.SystemBus
        service: "com.jolla.apkd"
        path: "/com/jolla/apkd"
        iface: "com.jolla.apkd"

        Component.onCompleted: {
            apkInterface.typedCall("isRunning", [],
                                   function(isRunning) {
                                       root.ready = true
                                       root.alienDalvikRunning = isRunning
                                   },
                                   function() {
                                       console.log("Error getting android state")
                                   })
        }
    }

    DBusInterface {
        id: dalvikService

        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        iface: "org.freedesktop.systemd1.Unit"
        signalsEnabled: true

        function updateProperties() {
            if (path !== "") {
                var activeState = dalvikService.getProperty("ActiveState")
                if (activeState === "active" || activeState === "inactive") {
                    root.busy = false
                }
                else {
                    root.busy = true
                }
                root.alienDalvikRunning = activeState === "active"
            } else {
                root.alienDalvikRunning = false
            }
        }

        onPropertiesChanged: runningUpdateTimer.start()
        onPathChanged: updateProperties()
    }

    DBusInterface {
        id: manager

        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"
        signalsEnabled: true

        signal unitNew(string name)
        onUnitNew: {
            if (name == "aliendalvik.service") {
                pathUpdateTimer.start()
            }
        }

        signal unitRemoved(string name)
        onUnitRemoved: {
            if (name == "aliendalvik.service") {
                dalvikService.path = ""
                pathUpdateTimer.stop()
            }
        }

        signal unitFilesChanged()
        onUnitFilesChanged: {
            updateAutostart()
        }

        Component.onCompleted: {
            updatePath()
            updateAutostart()
        }

        function updateAutostart() {
            manager.typedCall("GetUnitFileState", [{"type": "s", "value": "aliendalvik.service"}],
                              function(state) {
                                  if (state !== "disabled" && state !== "invalid") {
                                      root.alienDalvikAutostart = true
                                  } else {
                                      root.alienDalvikAutostart = false
                                  }
                              },
                              function() {
                                  root.alienDalvikAutostart = false
                              })
        }

        function updatePath() {
            manager.typedCall("GetUnit", [{ "type": "s", "value": "aliendalvik.service"}], function(unit) {
                dalvikService.path = unit
            }, function() {
                dalvikService.path = ""
            })
        }
    }

    Timer {
        // starting and stopping can result in lots of property changes
        id: runningUpdateTimer
        interval: 100
        onTriggered: dalvikService.updateProperties()
    }

    Timer {
        // stopping service can result in unit appearing and disappering, for some reason.
        id: pathUpdateTimer
        interval: 100
        onTriggered: manager.updatePath()
    }

    name: qsTr("Aliendalvik")
    icon.source: "image://theme/icon-m-android"
    available: root.ready
    checked: root.alienDalvikRunning
    onToggled: {
        if (root.busy) {
            return
        }

        if (checked) {
            apkInterface.typedCall("controlService", [{ "type": "b", "value": false }])
        }
        else {
            apkInterface.typedCall("controlService", [{ "type": "b", "value": true }])
        }
    }
}
