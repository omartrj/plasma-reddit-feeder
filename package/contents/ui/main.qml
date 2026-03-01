import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property string configuredSubreddits: Plasmoid.configuration.subreddit
    property int refreshInterval: Plasmoid.configuration.refreshInterval
    property string defaultSortOrder: Plasmoid.configuration.sortOrder
    property string iconStyle: Plasmoid.configuration.iconStyle

    property bool isFetching: false
    property string fetchError: ""
    property var activeSubredditList: []
    property string currentSubreddit: ""
    property string currentSortOrder: ""

    ListModel {
        id: postsModel
    }

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

    onConfiguredSubredditsChanged: updateSubredditList()
    onDefaultSortOrderChanged: {
        if (root.currentSortOrder === "") {
            root.currentSortOrder = root.defaultSortOrder
        }
    }
    onRefreshIntervalChanged: refreshTimer.restart()
    function parseConfiguredSubreddits(subsString) {
        var subs = subsString.split('+')
        var parsedList = []
        for (var i = 0; i < subs.length; i++) {
            var sub = subs[i].trim()
            if (sub !== "") {
                parsedList.push(sub)
            }
        }
        return parsedList
    }

    function updateSubredditList() {
        root.activeSubredditList = parseConfiguredSubreddits(root.configuredSubreddits)

        if (root.activeSubredditList.length > 0) {
            // fallback to first subreddit if current is removed from config
            if (root.activeSubredditList.indexOf(root.currentSubreddit) === -1) {
                root.currentSubreddit = root.activeSubredditList[0]
            }
        } else {
            root.currentSubreddit = ""
        }
        
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
                var status = 0;
                var text = "";
                try {
                    status = xhr.status;
                    text = xhr.responseText;
                } catch (e) {
                    // Component or backend network reply destroyed, safely ignore
                    return;
                }

                try {
                    root.isFetching = false
                    if (status === 200) {
                        processRedditResponse(text)
                    } else if (status !== 0) { // Ignore aborted connections (status 0)
                        root.fetchError = "Failed to fetch data (HTTP " + status + ")"
                        postsModel.clear()
                    }
                } catch (e) {
                    // Root object might be destroyed
                }
            }
        }
        xhr.setRequestHeader("User-Agent", "plasma-reddit-feeder/1.1 (KDE Plasma 6)")
        xhr.send()
    }

    function decodeHtmlEntities(text) {
        if (!text) return "";
        return text.replace(/&amp;/g, '&')
                   .replace(/&lt;/g, '<')
                   .replace(/&gt;/g, '>')
                   .replace(/&quot;/g, '"')
                   .replace(/&#39;/g, "'")
                   .replace(/&#x27;/g, "'");
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
                
                var decodedTitle = decodeHtmlEntities(child.title);

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

    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
