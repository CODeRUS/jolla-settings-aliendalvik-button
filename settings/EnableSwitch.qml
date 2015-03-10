import QtQuick 2.1
import Sailfish.Silica 1.0
import org.nemomobile.dbusnext 2.0
import Mer.Cutes 1.1

Switch {
    id: dalvikSwitch

    property string entryPath
    property string activeState
    onActiveStateChanged: {
        dalvikSwitch.busy = false
    }

    CutesActor {
        id: tools
        source: "./tools.js"
    }

    DBusInterface {
        id: systemdPropertiesIface
        service: 'org.freedesktop.systemd1'
        path: '/org/freedesktop/systemd1/unit/aliendalvik_2eservice'
        iface: 'org.freedesktop.systemd1.Unit'
        bus: DBus.SystemBus
    }

    DBusInterface {
        id: systemdSignalIface
        service: 'org.freedesktop.systemd1'
        path: '/org/freedesktop/systemd1/unit/aliendalvik_2eservice'
        iface: 'org.freedesktop.DBus.Properties'
        bus: DBus.SystemBus

        signalsEnabled: true

        signal rcPropertiesChanged(string interfaceName, variant changedProperties, variant invalidatedProperties)
        onRcPropertiesChanged: {
            if (interfaceName == "org.freedesktop.systemd1.Unit") {
                activeState = systemdPropertiesIface.getProperty("ActiveState")
            }
        }

        Component.onCompleted: {
            activeState = systemdPropertiesIface.getProperty("ActiveState")
        }
    }

    icon.source: "image://theme/icon-m-aliendalvik"
    checked: activeState == "active"
    automaticCheck: false
    onClicked: {
        if (dalvikSwitch.busy) {
            return
        }
        var on_reply = function() {
        };
        var on_error = function(err) {
            console.log("error:", err);
        };
        if (checked) {
            tools.request("stopAlien", {}, {
                on_reply: on_reply, on_error: on_error
            });
        }
        else {
            tools.request("restartAlien", {}, {
                on_reply: on_reply, on_error: on_error
            });
        }
        dalvikSwitch.busy = true
    }

    Behavior on opacity { FadeAnimation { } }
}
