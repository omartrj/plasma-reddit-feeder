import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot
    Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
    Layout.minimumHeight: Kirigami.Units.iconSizes.smallMedium
    
    Kirigami.Icon {
        anchors.fill: parent
        
        source: {
            if (root.iconStyle === "colored") return Qt.resolvedUrl("../images/icon.svg")
            if (root.iconStyle === "light") return Qt.resolvedUrl("../images/reddit-light.svg")
            if (root.iconStyle === "dark") return Qt.resolvedUrl("../images/reddit-dark.svg")
            
            // Automatic behavior (default)
            return "reddit"
        }
        
        fallback: {
            // When automatic is selected and "reddit" system icon fails, fallback to colored.
            if (root.iconStyle === "automatic" || root.iconStyle === "") {
                return Qt.resolvedUrl("../images/icon.svg")
            }
            return ""
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
