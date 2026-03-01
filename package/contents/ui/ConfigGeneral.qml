import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_subreddit: hiddenField.text
    property alias cfg_sortOrder: sortOrderField.currentValue
    property alias cfg_refreshInterval: refreshIntervalField.value

    TextField {
        id: hiddenField
        visible: false
        onTextChanged: {
            updateModelFromText(text)
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
        hiddenField.text = subs.join('+');
        updatingModel = false;
    }

    ListModel {
        id: subredditModel
    }

    RowLayout {
        Kirigami.FormData.label: "Add Subreddit:"
        Layout.fillWidth: true

        TextField {
            id: newSubredditField
            placeholderText: "e.g. kde"
            Layout.fillWidth: true
            onAccepted: addButton.clicked()
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

    Component.onCompleted: {
        updateModelFromText(hiddenField.text)
        
        // Find correct index for sortOrder ComboBox upon initialization
        var currentSort = hiddenField.parent.cfg_sortOrder.toLowerCase()
        for (var i = 0; i < sortOrderField.count; i++) {
            if (sortOrderField.textAt(i).toLowerCase() === currentSort) {
                sortOrderField.currentIndex = i
                break
            }
        }
    }

    ComboBox {
        id: sortOrderField
        Kirigami.FormData.label: "Default Sort:"
        model: ["Hot", "New", "Top", "Rising", "Best"]
        onCurrentTextChanged: {
            hiddenField.parent.cfg_sortOrder = currentText.toLowerCase()
        }
    }

    SpinBox {
        id: refreshIntervalField
        Kirigami.FormData.label: "Refresh Interval (minutes):"
        from: 1
        to: 1440
        stepSize: 1
        value: hiddenField.parent.cfg_refreshInterval
        onValueChanged: {
            hiddenField.parent.cfg_refreshInterval = value
        }
    }
}
