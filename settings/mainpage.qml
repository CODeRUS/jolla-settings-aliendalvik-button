import QtQuick 2.1
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import org.nemomobile.dbusnext 2.0
import Mer.Cutes 1.1

Page {
    id: page

    property string activeState
    onActiveStateChanged: {
        enableSwitch.busy = false
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

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width

            PageHeader {
                title: qsTr("Aliendalvik")
            }

            ListItem {
                id: enableItem

                contentHeight: enableSwitch.height
                _backgroundColor: "transparent"

                highlighted: enableSwitch.down || menuOpen

                showMenuOnPressAndHold: false
                menu: Component { FavoriteMenu { } }

                IconTextSwitch {
                    id: enableSwitch

                    property string entryPath: "system_settings/info/aliendalvik/aliendalvik_active"

                    automaticCheck: false
                    checked: activeState == "active"
                    highlighted: enableItem.highlighted
                    text: "Aliendalvik service state"
                    //description: qsTrId("settings_flight-la-flight-mode-description")
                    icon.source: "image://theme/icon-m-aliendalvik"

                    onClicked: {
                        if (enableSwitch.busy) {
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
                        enableSwitch.busy = true
                    }
                    onPressAndHold: enableItem.showMenu({ settingEntryPath: entryPath, isFavorite: favorites.isFavorite(entryPath) })

                }
            }
        }
    }
}
