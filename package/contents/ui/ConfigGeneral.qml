import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: page
    implicitWidth: Kirigami.Units.gridUnit * 25
    implicitHeight: Kirigami.Units.gridUnit * 35
    
    property string title: "Feed Settings"

    property string cfg_subreddit: ""
    property string cfg_subredditDefault: ""
    property string cfg_sortOrder: "hot"
    property alias cfg_refreshInterval: refreshIntervalField.value

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

    ScrollView {
        anchors.fill: parent
        // Needed so Kirigami.FormLayout doesn't keep expanding horizontally
        contentWidth: availableWidth
        clip: true

        Kirigami.FormLayout {
            // Take full width so labels wrap dynamically
            width: parent.width

            // SUBREDDIT FEED
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

            Rectangle {
                Kirigami.FormData.label: "Active:"
                Layout.fillWidth: true
                implicitHeight: Kirigami.Units.gridUnit * 12
                color: Kirigami.Theme.backgroundColor
                border.color: Kirigami.Theme.alternateBackgroundColor
                radius: Kirigami.Units.smallSpacing

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    
                    ListView {
                        id: subredditList
                        model: subredditModel
                        clip: true
                        spacing: Kirigami.Units.smallSpacing
                        
                        move: Transition {
                            NumberAnimation { properties: "y"; duration: 150; easing.type: Easing.OutQuad }
                        }
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            implicitHeight: rowLayout.implicitHeight + (Kirigami.Units.smallSpacing * 2)
                            color: Kirigami.Theme.backgroundColor
                            border.color: Kirigami.Theme.alternateBackgroundColor
                            radius: Kirigami.Units.smallSpacing

                            RowLayout {
                                id: rowLayout
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.smallSpacing
                                
                                Label {
                                    text: model.name
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                
                                ToolButton {
                                    icon.name: "go-up"
                                    display: AbstractButton.IconOnly
                                    Layout.alignment: Qt.AlignVCenter
                                    ToolTip.text: "Move Up"
                                    ToolTip.visible: hovered
                                    enabled: index > 0
                                    onClicked: {
                                        subredditModel.move(index, index - 1, 1)
                                        page.updateTextFromModel()
                                    }
                                }

                                ToolButton {
                                    icon.name: "go-down"
                                    display: AbstractButton.IconOnly
                                    Layout.alignment: Qt.AlignVCenter
                                    ToolTip.text: "Move Down"
                                    ToolTip.visible: hovered
                                    enabled: index < subredditModel.count - 1
                                    onClicked: {
                                        subredditModel.move(index, index + 1, 1)
                                        page.updateTextFromModel()
                                    }
                                }

                                ToolButton {
                                    id: removeButton
                                    icon.name: "list-remove"
                                    text: "Remove"
                                    display: AbstractButton.IconOnly
                                    Layout.alignment: Qt.AlignVCenter
                                    ToolTip.text: "Remove"
                                    ToolTip.visible: hovered
                                    onClicked: {
                                        subredditModel.remove(index)
                                        page.updateTextFromModel()
                                    }
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
            }

            // FETCHING AND SORT
            Item {
                Kirigami.FormData.label: "Fetching & Sort"
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
                from: 5
                to: 60
                stepSize: 1
            }
        }
    }
}
