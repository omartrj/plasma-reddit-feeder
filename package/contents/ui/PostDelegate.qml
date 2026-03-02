import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    width: ListView.view.width
    
    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Image {
            source: model.thumbnail ? model.thumbnail : ""
            visible: root.showThumbnails && model.thumbnail && model.thumbnail !== ""
            Layout.preferredWidth: Kirigami.Units.iconSizes.large
            Layout.preferredHeight: Kirigami.Units.iconSizes.large
            Layout.alignment: Qt.AlignTop
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Label {
                text: model.title
                font.bold: true
                font.pointSize: root.titleFontSize
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Label {
                text: "u/" + model.author
                opacity: 0.7
                font.pointSize: root.authorFontSize
                Layout.fillWidth: true
            }
        }
    }
    
    onClicked: {
        Qt.openUrlExternally(model.url)
    }
}
