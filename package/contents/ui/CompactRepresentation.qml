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
            if (root.iconStyle === "light") return Qt.resolvedUrl("../images/icon-light.svg")
            if (root.iconStyle === "dark") return Qt.resolvedUrl("../images/icon-dark.svg")
            
            // Fallback to colored
            return Qt.resolvedUrl("../images/icon.svg") 
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
