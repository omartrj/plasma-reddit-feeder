import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Kirigami.AbstractCard {
    width: ListView.view.width
    
    contentItem: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        ColumnLayout {
            id: textColumn
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            // author, date
            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                
                Label {
                    text: "u/" + model.author
                    opacity: 0.7
                    font.pointSize: root.authorFontSize
                }

                Label {
                    visible: root.showDate && model.created_utc !== ""
                    text: "• " + model.created_utc
                    opacity: 0.7
                    font.pointSize: root.authorFontSize
                }

                // Flair
                Rectangle {
                    visible: root.showFlairs && typeof model.flair_text !== "undefined" && model.flair_text !== ""
                    color: {
                        if (typeof model.flair_color !== "undefined" && model.flair_color !== "" && model.flair_color !== "transparent") {
                            return model.flair_color;
                        }
                        return Kirigami.Theme.highlightColor;
                    }
                    radius: Kirigami.Units.smallSpacing
                    implicitWidth: flairLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
                    implicitHeight: flairLabel.implicitHeight + Kirigami.Units.smallSpacing

                    Label {
                        id: flairLabel
                        text: typeof model.flair_text !== "undefined" ? model.flair_text : ""
                        font.pointSize: Math.max(8, root.authorFontSize - 1)
                        font.bold: true
                        color: {
                            if (typeof model.flair_color !== "undefined"  && model.flair_color !== "" && model.flair_color !== "transparent") {
                                let hex = model.flair_color.replace("#", "");
                                if (hex.length === 3) {
                                    hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
                                }
                                if (hex.length === 6) {
                                    let r = parseInt(hex.substr(0, 2), 16);
                                    let g = parseInt(hex.substr(2, 2), 16);
                                    let b = parseInt(hex.substr(4, 2), 16);
                                    // Calculate relative luminance to determine text color
                                    let luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;
                                    return luma > 128 ? "#000000" : "#ffffff";
                                }
                            }
                            return Kirigami.Theme.highlightedTextColor;
                        }
                        anchors.centerIn: parent
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Label {
                text: model.title
                font.bold: true
                font.pointSize: root.titleFontSize
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
            
            // Score, comments, tags
            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                visible: root.showScore || root.showComments || root.showTags

                // Tag NSFW
                Rectangle {
                    visible: root.showTags && model.over_18
                    color: Kirigami.Theme.negativeTextColor
                    radius: Kirigami.Units.smallSpacing
                    implicitWidth: nsfwLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
                    implicitHeight: nsfwLabel.implicitHeight + Kirigami.Units.smallSpacing

                    Label {
                        id: nsfwLabel
                        text: "NSFW"
                        font.pointSize: Math.max(6, root.authorFontSize - 2)
                        font.bold: true
                        color: Kirigami.Theme.backgroundColor
                        anchors.centerIn: parent
                    }
                }

                // Tag Spoiler
                Rectangle {
                    visible: root.showTags && model.spoiler
                    color: Kirigami.Theme.neutralTextColor
                    radius: Kirigami.Units.smallSpacing
                    implicitWidth: spoilerLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
                    implicitHeight: spoilerLabel.implicitHeight + Kirigami.Units.smallSpacing

                    Label {
                        id: spoilerLabel
                        text: "SPOILER"
                        font.pointSize: Math.max(6, root.authorFontSize - 2)
                        font.bold: true
                        color: Kirigami.Theme.backgroundColor
                        anchors.centerIn: parent
                    }
                }

                // Score
                RowLayout {
                    visible: root.showScore
                    spacing: Kirigami.Units.smallSpacing / 2
                    Kirigami.Icon {
                        source: "arrow-up-double"
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        color: Kirigami.Theme.textColor
                    }
                    Label {
                        text: model.score
                        font.pointSize: root.authorFontSize
                        opacity: 0.8
                    }
                }

                // Comments
                RowLayout {
                    visible: root.showComments
                    spacing: Kirigami.Units.smallSpacing / 2
                    Kirigami.Icon {
                        source: "edit-comment"
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        color: Kirigami.Theme.textColor
                    }
                    Label {
                        text: model.num_comments
                        font.pointSize: root.authorFontSize
                        opacity: 0.8
                    }
                }
            }
        }

        Item {
            visible: root.showThumbnails && model.thumbnail && model.thumbnail !== ""
            
            // Adapt to the height of the text column to keep it proportional to the text
            // Ensure minimum size for 1-line posts
            // Ensure maximum size for excessively long posts
            readonly property real boundedSize: {
                let textHeight = textColumn.implicitHeight;
                let minSize = Kirigami.Units.iconSizes.huge;
                let maxSize = Kirigami.Units.iconSizes.enormous;
                
                return Math.min(maxSize, Math.max(minSize, textHeight));
            }
            
            Layout.preferredHeight: boundedSize
            Layout.preferredWidth: boundedSize
            Layout.alignment: Qt.AlignTop

            Image {
                anchors.fill: parent
                source: model.thumbnail ? model.thumbnail : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                // "Blur" effect by heavily reducing opacity if it's sensitive content
                opacity: (root.showTags && (model.over_18 || model.spoiler)) ? 0.15 : 1.0
                
                Behavior on opacity {
                    NumberAnimation { duration: Kirigami.Units.shortDuration }
                }
            }
            
            // Icon to indicate content is hidden over the thumbnail
            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: width
                source: "view-hidden"
                visible: root.showTags && (model.over_18 || model.spoiler)
                opacity: 0.8
            }
        }
    }
    
    onClicked: {
        Qt.openUrlExternally(model.url)
    }
}
