import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    width: ListView.view.width
    
    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Label {
                text: model.title
                font.bold: true
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Label {
                text: "u/" + model.author
                opacity: 0.7
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                Layout.fillWidth: true
            }
        }
    }
    
    onClicked: {
        Qt.openUrlExternally(model.url)
    }
}
