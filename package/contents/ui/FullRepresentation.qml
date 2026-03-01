import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: fullRoot
    Layout.minimumWidth: Kirigami.Units.gridUnit * 14
    Layout.preferredWidth: Kirigami.Units.gridUnit * 18
    Layout.minimumHeight: Kirigami.Units.gridUnit * 24

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            TabBar {
                id: subredditTabBar
                Layout.fillWidth: true
                clip: true
                
                Repeater {
                    model: root.activeSubredditList
                    delegate: TabButton {
                        text: "r/" + modelData
                        width: implicitWidth
                    }
                }

                onCurrentIndexChanged: {
                    if (currentIndex >= 0 && currentIndex < root.activeSubredditList.length) {
                        root.currentSubreddit = root.activeSubredditList[currentIndex]
                        root.fetchRedditData()
                    }
                }
            }

            ToolButton {
                icon.name: "view-sort"
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignVCenter
                
                ToolTip.text: "Sort: " + root.currentSortOrder.charAt(0).toUpperCase() + root.currentSortOrder.slice(1)
                ToolTip.visible: hovered

                onClicked: sortMenu.open()

                Menu {
                    id: sortMenu
                    y: parent.height

                    ActionGroup {
                        id: sortGroup
                        exclusive: true
                    }
                    
                    MenuItem {
                        text: "Best"
                        checkable: true
                        ActionGroup.group: sortGroup
                        checked: root.currentSortOrder === "best"
                        onTriggered: {
                            root.currentSortOrder = "best"
                            root.fetchRedditData()
                        }
                    }
                    MenuItem {
                        text: "Hot"
                        checkable: true
                        ActionGroup.group: sortGroup
                        checked: root.currentSortOrder === "hot"
                        onTriggered: {
                            root.currentSortOrder = "hot"
                            root.fetchRedditData()
                        }
                    }
                    MenuItem {
                        text: "New"
                        checkable: true
                        ActionGroup.group: sortGroup
                        checked: root.currentSortOrder === "new"
                        onTriggered: {
                            root.currentSortOrder = "new"
                            root.fetchRedditData()
                        }
                    }
                    MenuItem {
                        text: "Top"
                        checkable: true
                        ActionGroup.group: sortGroup
                        checked: root.currentSortOrder === "top"
                        onTriggered: {
                            root.currentSortOrder = "top"
                            root.fetchRedditData()
                        }
                    }
                    MenuItem {
                        text: "Rising"
                        checkable: true
                        ActionGroup.group: sortGroup
                        checked: root.currentSortOrder === "rising"
                        onTriggered: {
                            root.currentSortOrder = "rising"
                            root.fetchRedditData()
                        }
                    }
                }
            }

            ToolButton {
                icon.name: "window-pin"
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignVCenter
                checkable: true
                checked: !root.hideOnWindowDeactivate
                onToggled: {
                    root.hideOnWindowDeactivate = !checked
                }
                ToolTip.text: checked ? "Unpin Widget" : "Keep Open"
                ToolTip.visible: hovered
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                anchors.fill: parent
                model: postsModel
                clip: true
                spacing: Kirigami.Units.smallSpacing

                delegate: PostDelegate {}
            }

            // Overlay for Error or Empty State
            Kirigami.PlaceholderMessage {
                anchors.centerIn: parent
                width: parent.width - (Kirigami.Units.largeSpacing * 2)
                visible: postsModel.count === 0
                text: root.isFetching ? "Loading Posts..." : (root.fetchError !== "" ? root.fetchError : "No posts found")
                icon.name: root.isFetching ? "view-refresh" : (root.fetchError !== "" ? "network-disconnect" : "application-rss+xml")
            }
        }
    }
}
