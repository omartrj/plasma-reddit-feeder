import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "Constants.js" as C

Item {
    id: page
    implicitWidth: Kirigami.Units.gridUnit * C.CONFIG_PAGE_WIDTH_GU
    implicitHeight: Kirigami.Units.gridUnit * C.CONFIG_PAGE_HEIGHT_GU
    
    property string title: "Appearance"

    property string cfg_iconStyle: "colored"
    property alias cfg_showThumbnails: showThumbnailsField.checked
    property alias cfg_showScore: showScoreField.checked
    property alias cfg_showComments: showCommentsField.checked
    property alias cfg_showFlairs: showFlairsField.checked
    property alias cfg_showTags: showTagsField.checked
    property alias cfg_showDate: showDateField.checked
    property alias cfg_titleFontSize: titleFontSizeField.value
    property alias cfg_authorFontSize: authorFontSizeField.value

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        Kirigami.FormLayout {
            width: parent.width

            // APPEARANCE
            Item {
                Kirigami.FormData.label: "Appearance"
                Kirigami.FormData.isSection: true
            }

            ComboBox {
                id: iconStyleField
                Kirigami.FormData.label: "Widget Icon:"
                model: ["Colored", "Light", "Dark"]
                currentIndex: {
                    let idx = ["colored", "light", "dark"].indexOf(page.cfg_iconStyle.toLowerCase());
                    return idx >= 0 ? idx : 0;
                }
                onActivated: {
                    page.cfg_iconStyle = currentText.toLowerCase()
                }
            }

            CheckBox {
                id: showThumbnailsField
                Kirigami.FormData.label: "Visuals:"
                text: "Show post thumbnails"
            }

            // POST METADATA
            Item {
                Kirigami.FormData.label: "Post Metadata"
                Kirigami.FormData.isSection: true
            }

            CheckBox {
                id: showFlairsField
                Kirigami.FormData.label: "Flairs:"
                text: "Show post flairs (e.g. News, Discussion)"
            }

            CheckBox {
                id: showTagsField
                Kirigami.FormData.label: "Tags:"
                text: "Blur NSFW/Spoiler content"
            }

            CheckBox {
                id: showScoreField
                Kirigami.FormData.label: "Score:"
                text: "Show post upvotes"
            }

            CheckBox {
                id: showCommentsField
                Kirigami.FormData.label: "Comments:"
                text: "Show comment count"
            }

            CheckBox {
                id: showDateField
                Kirigami.FormData.label: "Date:"
                text: "Show relative publishing date"
            }

            // FONTS
            Item {
                Kirigami.FormData.label: "Fonts"
                Kirigami.FormData.isSection: true
            }

            RowLayout {
                Kirigami.FormData.label: "Title Font Size:"
                Layout.fillWidth: true

                Slider {
                    id: titleFontSizeSlider
                    Layout.fillWidth: true
                    from: 6
                    to: 24
                    stepSize: 1
                    value: titleFontSizeField.value
                    onValueChanged: titleFontSizeField.value = value
                }

                SpinBox {
                    id: titleFontSizeField
                    from: 6
                    to: 24
                    stepSize: 1
                    value: titleFontSizeSlider.value
                    onValueChanged: titleFontSizeSlider.value = value
                }
            }

            RowLayout {
                Kirigami.FormData.label: "Author Font Size:"
                Layout.fillWidth: true

                Slider {
                    id: authorFontSizeSlider
                    Layout.fillWidth: true
                    from: 6
                    to: 24
                    stepSize: 1
                    value: authorFontSizeField.value
                    onValueChanged: authorFontSizeField.value = value
                }

                SpinBox {
                    id: authorFontSizeField
                    from: 6
                    to: 24
                    stepSize: 1
                    value: authorFontSizeSlider.value
                    onValueChanged: authorFontSizeSlider.value = value
                }
            }
        }
    }
}
