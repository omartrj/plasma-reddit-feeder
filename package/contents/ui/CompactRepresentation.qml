import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot
    Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
    Layout.minimumHeight: Kirigami.Units.iconSizes.smallMedium
    
    Kirigami.Icon {
        anchors.fill: parent
        source: "reddit"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
