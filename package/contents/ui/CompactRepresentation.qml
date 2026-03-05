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
            if (root.iconStyle === "colored") return Qt.resolvedUrl("../assets/icon.svg")
            if (root.iconStyle === "light") return Qt.resolvedUrl("../assets/icon-light.svg")
            if (root.iconStyle === "dark") return Qt.resolvedUrl("../assets/icon-dark.svg")
            
            // Fallback to colored
            return Qt.resolvedUrl("../assets/icon.svg") 
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
