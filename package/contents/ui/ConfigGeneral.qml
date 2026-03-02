import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page
    
    // The "title" property is sometimes expected by parent containers in KCM/System Settings
    property string title: "General"

    // Automatically bound config properties
    property string cfg_subreddit: ""
    property string cfg_subredditDefault: ""
    property string cfg_sortOrder: "hot"
    property string cfg_iconStyle: "automatic"
    property alias cfg_refreshInterval: refreshIntervalField.value
    property alias cfg_showThumbnails: showThumbnailsField.checked

    onCfg_subredditChanged: updateModelFromText(cfg_subreddit)

    property bool updatingModel: false

    function updateModelFromText(text) {
        if (updatingModel) return;
        updatingModel = true;
        subredditModel.clear();
        let subs = text.split('+');
        for (let i = 0; i < subs.length; i++) {
            let subName = subs[i].trim();
            if (subName !== "") {
                subredditModel.append({"name": subName});
            }
        }
        updatingModel = false;
    }

    function updateTextFromModel() {
        if (updatingModel) return;
        updatingModel = true;
        let subs = [];
        for (let i = 0; i < subredditModel.count; i++) {
            subs.push(subredditModel.get(i).name);
        }
        page.cfg_subreddit = subs.join('+');
        updatingModel = false;
    }

    ListModel {
        id: subredditModel
    }

    Item {
        Kirigami.FormData.label: "Reddit Feed"
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: "Add Subreddit:"
        Layout.fillWidth: true

        TextField {
            id: newSubredditField
            placeholderText: "e.g. kde"
            Layout.fillWidth: true
            onAccepted: {
                if (addButton.enabled) {
                    addButton.clicked()
                }
            }
        }

        Button {
            id: addButton
            icon.name: "list-add"
            text: "Add"
            enabled: newSubredditField.text.trim() !== ""
            onClicked: {
                subredditModel.append({"name": newSubredditField.text.trim()})
                newSubredditField.text = ""
                page.updateTextFromModel()
            }
        }
    }

    ScrollView {
        Layout.fillWidth: true
        implicitHeight: Kirigami.Units.gridUnit * 6
        Layout.maximumHeight: Kirigami.Units.gridUnit * 6
        
        ListView {
            id: subredditList
            model: subredditModel
            clip: true
            
            delegate: RowLayout {
                width: ListView.view.width
                
                Label {
                    text: model.name
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                
                ToolButton {
                    icon.name: "list-remove"
                    text: "Remove"
                    display: AbstractButton.IconOnly
                    onClicked: {
                        subredditModel.remove(index)
                        page.updateTextFromModel()
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                text: "No subreddits added."
                visible: subredditModel.count === 0
                opacity: 0.6
            }
        }
    }

    Item {
        Kirigami.FormData.label: "Preferences"
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        id: sortOrderField
        Kirigami.FormData.label: "Default Sort:"
        model: ["Hot", "New", "Top", "Rising", "Best"]
        currentIndex: {
            let idx = ["hot", "new", "top", "rising", "best"].indexOf(page.cfg_sortOrder.toLowerCase());
            return idx >= 0 ? idx : 0;
        }
        onActivated: {
            page.cfg_sortOrder = currentText.toLowerCase()
        }
    }

    SpinBox {
        id: refreshIntervalField
        Kirigami.FormData.label: "Refresh Interval (minutes):"
        from: 1
        to: 1440
        stepSize: 1
    }

    ComboBox {
        id: iconStyleField
        Kirigami.FormData.label: "Icon Style:"
        model: ["Automatic", "Colored", "Light", "Dark"]
        currentIndex: {
            let idx = ["automatic", "colored", "light", "dark"].indexOf(page.cfg_iconStyle.toLowerCase());
            return idx >= 0 ? idx : 0;
        }
        onActivated: {
            page.cfg_iconStyle = currentText.toLowerCase()
        }
    }

    CheckBox {
        id: showThumbnailsField
        Kirigami.FormData.label: "Thumbnails:"
        text: "Show images next to posts"
    }
}
