import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import "../Utils.js" as Utils
import "../Constants.js" as C

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
                    text: `u/${model.author}`
                    opacity: C.OPACITY_MUTED
                    font.pointSize: root.authorFontSize
                }

                Label {
                    visible: root.showDate && model.created_utc !== ""
                    text: `• ${model.created_utc}`
                    opacity: C.OPACITY_MUTED
                    font.pointSize: root.authorFontSize
                }

                // Flair
                Rectangle {
                    visible: root.showFlairs && typeof model.flair_text !== "undefined" && model.flair_text !== ""
                    color: {
                        if (model.flair_color && model.flair_color !== "transparent") {
                            return model.flair_color;
                        }
                        return Kirigami.Theme.highlightColor;
                    }
                    radius: Kirigami.Units.smallSpacing
                    implicitWidth: flairLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
                    implicitHeight: flairLabel.implicitHeight + Kirigami.Units.smallSpacing

                    Label {
                        id: flairLabel
                        text: model.flair_text ?? ""
                        font.pointSize: Math.max(8, root.authorFontSize - 1)
                        font.bold: true
                        color: {
                            if (model.flair_color && model.flair_color !== "transparent") {
                                let hex = model.flair_color.replace("#", "");
                                if (hex.length === 3) {
                                    hex = `${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}`;
                                }
                                if (hex.length === 6) {
                                    const r = parseInt(hex.substr(0, 2), 16);
                                    const g = parseInt(hex.substr(2, 2), 16);
                                    const b = parseInt(hex.substr(4, 2), 16);
                                    const luma = Utils.getLuminance(r, g, b);
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
                        source: C.ICON_SCORE
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        color: Kirigami.Theme.textColor
                    }
                    Label {
                        text: model.score
                        font.pointSize: root.authorFontSize
                        opacity: C.OPACITY_MUTED
                    }
                }

                // Comments
                RowLayout {
                    visible: root.showComments
                    spacing: Kirigami.Units.smallSpacing / 2
                    Kirigami.Icon {
                        source: C.ICON_COMMENTS
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        color: Kirigami.Theme.textColor
                    }
                    Label {
                        text: model.num_comments
                        font.pointSize: root.authorFontSize
                        opacity: C.OPACITY_MUTED
                    }
                }
            }
        }

        Item {
            visible: root.showThumbnails && model.thumbnail && model.thumbnail !== ""
            
            readonly property real boundedSize: {
                const textHeight = textColumn.implicitHeight;
                const minSize = Kirigami.Units.gridUnit * C.THUMBNAIL_MIN_SIZE_GU;
                const maxSize = Kirigami.Units.gridUnit * C.THUMBNAIL_MAX_SIZE_GU;
                
                return Math.min(maxSize, Math.max(minSize, textHeight));
            }
            
            Layout.preferredHeight: boundedSize
            Layout.preferredWidth: boundedSize
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.fill: parent
                source: model.thumbnail ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                // "Blur" effect by heavily reducing opacity if it's sensitive content
                opacity: (root.showTags && (model.over_18 || model.spoiler)) ? C.THUMBNAIL_OPACITY_SENSITIVE : 1.0
                
                Behavior on opacity {
                    NumberAnimation { duration: Kirigami.Units.shortDuration }
                }
            }
            
            // Icon to indicate content is hidden over the thumbnail
            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: width
                source: C.ICON_HIDDEN
                visible: root.showTags && (model.over_18 || model.spoiler)
                opacity: C.OPACITY_MUTED
            }
        }
    }
    
    onClicked: {
        Qt.openUrlExternally(model.url)
    }
}
