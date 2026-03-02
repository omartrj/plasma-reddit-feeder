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
    property var currentRequest: null

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
        return subsString.split('+').map(s => s.trim()).filter(s => s !== "")
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

        if (root.currentRequest) {
            root.currentRequest.abort()
        }

        root.isFetching = true
        root.fetchError = ""
        postsModel.clear()
        
        let xhr = new XMLHttpRequest()
        root.currentRequest = xhr
        let targetUrl = "https://www.reddit.com/r/" + root.currentSubreddit + "/" + (root.currentSortOrder || "hot") + ".json"
        
        xhr.open("GET", targetUrl)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (root.currentRequest === xhr) {
                    root.currentRequest = null
                }
                
                let status = 0;
                let text = "";
                try {
                    status = xhr.status;
                    text = xhr.responseText;
                } catch (e) {
                    return;
                }

                try {
                    // Ignore aborted connections (status 0)
                    if (status === 0) {
                        return;
                    }
                    root.isFetching = false
                    if (status === 200) {
                        processRedditResponse(text)
                    } else {
                        root.fetchError = "Failed to fetch data (HTTP " + status + ")"
                    }
                } catch (e) {
                }
            }
        }
        xhr.setRequestHeader("User-Agent", "plasma-reddit-feeder/1.2 (KDE Plasma 6)")
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
            let json = JSON.parse(responseText)
            if (!json || !json.data || !json.data.children) {
                root.fetchError = "Invalid data format received"
                return
            }

            let posts = json.data.children

            for (let i = 0; i < posts.length; i++) {
                let child = posts[i].data
                let permalink = "https://www.reddit.com" + child.permalink
                
                let decodedTitle = decodeHtmlEntities(child.title);

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
