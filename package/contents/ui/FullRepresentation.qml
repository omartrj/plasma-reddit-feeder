import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "js/Constants.js" as C

Item {
    id: fullRoot
    Layout.minimumWidth: Kirigami.Units.gridUnit * C.PANEL_MIN_WIDTH_GU
    Layout.preferredWidth: Kirigami.Units.gridUnit * C.PANEL_PREFERRED_WIDTH_GU
    Layout.minimumHeight: Kirigami.Units.gridUnit * C.PANEL_MIN_HEIGHT_GU

    property int now: Math.floor(Date.now() / 1000)

    Timer {
        id: ageTimer
        interval: C.AGE_LABEL_UPDATE_INTERVAL_MS
        repeat: true
        running: true
        onTriggered: fullRoot.now = Math.floor(Date.now() / 1000)
    }

    function ageText() {
        if (root.isBackingOff) return "Rate limited — wait"
        if (root.lastFetchTime === 0) return "Not yet updated"
        const mins = Math.floor((fullRoot.now - root.lastFetchTime) / 60)
        if (mins < 1) return "Updated just now"
        if (mins === 1) return "Updated 1 min ago"
        return `Updated ${mins} min ago`
    }

    function resetScroll() {
        if (listView) {
            listView.positionViewAtBeginning()
        }
    }

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
                
                currentIndex: {
                    const idx = root.activeSubredditList?.indexOf(root.currentSubreddit) ?? -1;
                    return idx >= 0 ? idx : 0;
                }
                
                Repeater {
                    model: root.activeSubredditList
                    delegate: TabButton {
                        text: `r/${modelData}`
                        width: implicitWidth
                    }
                }

                onCurrentIndexChanged: {
                    if (root.activeSubredditList?.[currentIndex]) {
                        const newlySelected = root.activeSubredditList[currentIndex]
                        if (root.currentSubreddit !== newlySelected) {
                            root.currentSubreddit = newlySelected
                            root.currentSortOrder = root.defaultSortOrder
                            root.loadCurrentSubredditFromCache()
                            listView.positionViewAtBeginning()
                        }
                    }
                }
            }

            ToolButton {
                icon.name: C.ICON_SORT
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignVCenter
                
                ToolTip.text: `Sort: ${root.currentSortOrder.charAt(0).toUpperCase()}${root.currentSortOrder.slice(1)}`
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
                            listView.positionViewAtBeginning()
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
                            listView.positionViewAtBeginning()
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
                            listView.positionViewAtBeginning()
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
                            listView.positionViewAtBeginning()
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
                            listView.positionViewAtBeginning()
                        }
                    }
                }
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
                icon.name: root.isFetching ? C.ICON_REFRESH : (root.fetchError !== "" ? C.ICON_ERROR : C.ICON_FEED)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            Layout.topMargin: 2
            Layout.bottomMargin: 2

            ToolButton {
                icon.name: C.ICON_REFRESH
                icon.width: Kirigami.Units.iconSizes.small
                icon.height: Kirigami.Units.iconSizes.small
                display: AbstractButton.IconOnly
                flat: true
                enabled: !root.isBackingOff && !root.isFetching
                onClicked: root.fetchAllSubreddits()
                ToolTip.text: "Refresh now"
                ToolTip.visible: hovered
            }

            Label {
                text: fullRoot.ageText()
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                color: Kirigami.Theme.disabledTextColor
                Layout.fillWidth: true
            }

            ToolButton {
                icon.name: C.ICON_PIN
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignVCenter
                checkable: true
                checked: !root.hideOnWindowDeactivate

                // Only show this button if we are in a popup from a panel
                visible: Plasmoid.location !== PlasmaCore.Types.Floating

                onToggled: {
                    root.hideOnWindowDeactivate = !checked
                }
                ToolTip.text: "Keep open"
                ToolTip.visible: hovered
            }
        }
    }

    Connections {
        target: root
        function onNewDataAvailable() {
            fullRoot.resetScroll()
        }
        function onExpandedChanged() {
            if (root.expanded) {
                fullRoot.resetScroll()
            }
        }
    }
}
