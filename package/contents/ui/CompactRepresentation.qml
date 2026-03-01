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
            if (root.iconStyle === "colored") return Qt.resolvedUrl("../images/icon.svg").toString().replace("file://", "")
            if (root.iconStyle === "light") return Qt.resolvedUrl("../images/reddit-light.svg").toString().replace("file://", "")
            if (root.iconStyle === "dark") return Qt.resolvedUrl("../images/reddit-dark.svg").toString().replace("file://", "")
            
            // Automatic behavior (default)
            return "reddit"
        }
        
        fallback: {
            // When automatic is selected and "reddit" system icon fails, fallback to colored.
            if (root.iconStyle === "automatic" || root.iconStyle === "") {
                return Qt.resolvedUrl("../images/icon.svg").toString().replace("file://", "")
            }
            return ""
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
