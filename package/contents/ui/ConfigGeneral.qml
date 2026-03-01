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
    property string cfg_sortOrderDefault: "hot"
    
    property int cfg_refreshInterval: 10
    property int cfg_refreshIntervalDefault: 15
    
    property string cfg_iconStyle: "automatic"
    property string cfg_iconStyleDefault: "automatic"

    onCfg_subredditChanged: updateModelFromText(cfg_subreddit)
    onCfg_sortOrderChanged: {
        var currentSort = cfg_sortOrder.toLowerCase()
        for (var i = 0; i < sortOrderField.count; i++) {
            if (sortOrderField.textAt(i).toLowerCase() === currentSort) {
                sortOrderField.currentIndex = i
                break
            }
        }
    }
    onCfg_iconStyleChanged: {
        var currentStyle = cfg_iconStyle.toLowerCase()
        for (var i = 0; i < iconStyleField.count; i++) {
            if (iconStyleField.textAt(i).toLowerCase() === currentStyle) {
                iconStyleField.currentIndex = i
                break
            }
        }
    }

    property bool updatingModel: false

    function updateModelFromText(text) {
        if (updatingModel) return;
        updatingModel = true;
        subredditModel.clear();
        var subs = text.split('+');
        for (var i = 0; i < subs.length; i++) {
            var subName = subs[i].trim();
            if (subName !== "") {
                subredditModel.append({"name": subName});
            }
        }
        updatingModel = false;
    }

    function updateTextFromModel() {
        if (updatingModel) return;
        updatingModel = true;
        var subs = [];
        for (var i = 0; i < subredditModel.count; i++) {
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
            Keys.onReturnPressed: (event) => {
                event.accepted = true
                if (addButton.enabled) {
                    addButton.clicked()
                }
            }
            Keys.onEnterPressed: (event) => {
                event.accepted = true
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
                updateTextFromModel()
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
                        updateTextFromModel()
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
        onCurrentTextChanged: {
            page.cfg_sortOrder = currentText.toLowerCase()
        }
    }

    SpinBox {
        id: refreshIntervalField
        Kirigami.FormData.label: "Refresh Interval (minutes):"
        from: 1
        to: 1440
        stepSize: 1
        value: page.cfg_refreshInterval
        onValueChanged: {
            page.cfg_refreshInterval = value
        }
    }

    ComboBox {
        id: iconStyleField
        Kirigami.FormData.label: "Icon Style:"
        model: ["Automatic", "Colored", "Light", "Dark"]
        onCurrentTextChanged: {
            page.cfg_iconStyle = currentText.toLowerCase()
        }
    }
}
