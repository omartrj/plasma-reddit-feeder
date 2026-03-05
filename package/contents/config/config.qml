import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "configure"
        source: "config/ConfigGeneral.qml"
    }
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-theme"
        source: "config/ConfigAppearance.qml"
    }
}
