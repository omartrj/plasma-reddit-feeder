import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // --- Configuration Properties ---
    property string configuredSubreddits: Plasmoid.configuration.subreddit
    property int refreshInterval: Plasmoid.configuration.refreshInterval
    property string defaultSortOrder: Plasmoid.configuration.sortOrder

    // --- State Properties ---
    property bool isFetching: false
    property string fetchError: ""
    property var activeSubredditList: []
    property string currentSubreddit: ""
    property string currentSortOrder: ""

    // --- Models ---
    ListModel {
        id: postsModel
    }

    // --- Lifecycle and Timers ---
    Timer {
        id: refreshTimer
        interval: root.refreshInterval * 60 * 1000
        running: true
        repeat: true
        onTriggered: fetchRedditData()
    }

    Component.onCompleted: {
        root.currentSortOrder = root.defaultSortOrder
        updateSubredditList()
    }

    // --- Property Observers ---
    onConfiguredSubredditsChanged: updateSubredditList()
    onDefaultSortOrderChanged: {
        if (root.currentSortOrder === "") {
            root.currentSortOrder = root.defaultSortOrder
        }
    }
    onRefreshIntervalChanged: refreshTimer.restart()

    // --- Methods ---
    function updateSubredditList() {
        var subs = root.configuredSubreddits.split('+')
        var parsedList = []
        for (var i = 0; i < subs.length; i++) {
            var sub = subs[i].trim()
            if (sub !== "") {
                parsedList.push(sub)
            }
        }
        root.activeSubredditList = parsedList

        if (root.activeSubredditList.length > 0) {
            // Default to the first configured subreddit if none is currently valid
            if (root.activeSubredditList.indexOf(root.currentSubreddit) === -1) {
                root.currentSubreddit = root.activeSubredditList[0]
            }
        } else {
            root.currentSubreddit = ""
        }
        
        // Force refresh
        fetchRedditData()
    }

    function fetchRedditData() {
        if (!root.currentSubreddit || root.currentSubreddit === "") {
            postsModel.clear()
            root.fetchError = "No subreddits configured"
            return
        }

        root.isFetching = true
        root.fetchError = ""
        postsModel.clear()
        
        var xhr = new XMLHttpRequest()
        var targetUrl = "https://www.reddit.com/r/" + root.currentSubreddit + "/" + (root.currentSortOrder || "hot") + ".json"
        
        xhr.open("GET", targetUrl)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.isFetching = false
                if (xhr.status === 200) {
                    processRedditResponse(xhr.responseText)
                } else {
                    root.fetchError = "Failed to fetch data (HTTP " + xhr.status + ")"
                    postsModel.clear()
                }
            }
        }
        xhr.setRequestHeader("User-Agent", "plasma-reddit-feeder/1.1 (KDE Plasma 6)")
        xhr.send()
    }

    function processRedditResponse(responseText) {
        try {
            var json = JSON.parse(responseText)
            if (!json || !json.data || !json.data.children) {
                root.fetchError = "Invalid data format received"
                return
            }

            postsModel.clear()
            var posts = json.data.children

            for (var i = 0; i < posts.length; i++) {
                var child = posts[i].data
                var permalink = "https://www.reddit.com" + child.permalink
                
                postsModel.append({
                    "title": child.title,
                    "author": child.author,
                    "url": permalink
                })
            }
        } catch (e) {
            root.fetchError = "Error parsing response: " + e.toString()
            postsModel.clear()
        }
    }

    // --- User Interface ---
    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 18
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
                    text: root.currentSortOrder.charAt(0).toUpperCase() + root.currentSortOrder.slice(1)
                    display: AbstractButton.TextBesideIcon
                    Layout.alignment: Qt.AlignVCenter

                    onClicked: sortMenu.open()

                    Menu {
                        id: sortMenu
                        y: parent.height
                        
                        MenuItem {
                            text: "Best"
                            checked: root.currentSortOrder === "best"
                            onTriggered: {
                                root.currentSortOrder = "best"
                                root.fetchRedditData()
                            }
                        }
                        MenuItem {
                            text: "Hot"
                            checked: root.currentSortOrder === "hot"
                            onTriggered: {
                                root.currentSortOrder = "hot"
                                root.fetchRedditData()
                            }
                        }
                        MenuItem {
                            text: "New"
                            checked: root.currentSortOrder === "new"
                            onTriggered: {
                                root.currentSortOrder = "new"
                                root.fetchRedditData()
                            }
                        }
                        MenuItem {
                            text: "Top"
                            checked: root.currentSortOrder === "top"
                            onTriggered: {
                                root.currentSortOrder = "top"
                                root.fetchRedditData()
                            }
                        }
                        MenuItem {
                            text: "Rising"
                            checked: root.currentSortOrder === "rising"
                            onTriggered: {
                                root.currentSortOrder = "rising"
                                root.fetchRedditData()
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

                    delegate: Kirigami.AbstractCard {
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
}
