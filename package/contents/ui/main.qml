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
                
                var decodedTitle = child.title.replace(/&amp;/g, '&')
                                              .replace(/&lt;/g, '<')
                                              .replace(/&gt;/g, '>')
                                              .replace(/&quot;/g, '"')
                                              .replace(/&#39;/g, "'")
                                              .replace(/&#x27;/g, "'");

                postsModel.append({
                    "title": decodedTitle,
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
    compactRepresentation: CompactRepresentation {}

    fullRepresentation: FullRepresentation {}
}
