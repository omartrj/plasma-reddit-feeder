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
    property bool showThumbnails: Plasmoid.configuration.showThumbnails
    property int titleFontSize: Plasmoid.configuration.titleFontSize
    property int authorFontSize: Plasmoid.configuration.authorFontSize
    property bool showScore: Plasmoid.configuration.showScore
    property bool showComments: Plasmoid.configuration.showComments
    property bool showFlairs: Plasmoid.configuration.showFlairs
    property bool showTags: Plasmoid.configuration.showTags
    property bool showDate: Plasmoid.configuration.showDate

    property bool isFetching: false
    property string fetchError: ""
    property var activeSubredditList: []
    property string currentSubreddit: ""
    property string currentSortOrder: ""
    property var currentRequest: null
    property var redditCache: ({}) // Stores cached JSON responses
    property var activeBackgroundRequests: ({}) // Prevent GC of background XHRs

    ListModel {
        id: postsModel
    }

    Timer {
        id: refreshTimer
        interval: root.refreshInterval * 60 * 1000
        running: true
        repeat: true
        onTriggered: fetchAllSubreddits()
    }

    Component.onCompleted: {
        root.currentSortOrder = root.defaultSortOrder
        updateSubredditList()
    }

    onExpandedChanged: {
        if (expanded) {
            fetchAllSubreddits()
        }
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
        
        fetchAllSubreddits()
    }

    function fetchAllSubreddits() {
        if (!root.activeSubredditList || root.activeSubredditList.length === 0) return
        
        let sortMode = root.currentSortOrder || "hot"
        
        for (let i = 0; i < root.activeSubredditList.length; i++) {
            let sub = root.activeSubredditList[i]
            let cacheKey = sub + "_" + sortMode
            
            let bgXhr = new XMLHttpRequest()
            root.activeBackgroundRequests[cacheKey] = bgXhr // prevent GC destruction
            
            let targetUrl = "https://www.reddit.com/r/" + sub + "/" + sortMode + ".json"
            
            bgXhr.open("GET", targetUrl)
            bgXhr.onreadystatechange = function() {
                if (bgXhr.readyState === XMLHttpRequest.DONE) {
                    if (bgXhr.status === 200) {
                        root.redditCache[cacheKey] = bgXhr.responseText
                        if (sub === root.currentSubreddit && sortMode === (root.currentSortOrder || "hot")) {
                            root.isFetching = false
                            root.fetchError = ""
                            processRedditResponse(bgXhr.responseText, false)
                        }
                    } else if (sub === root.currentSubreddit && sortMode === (root.currentSortOrder || "hot")) {
                        root.isFetching = false
                        root.fetchError = "Failed to fetch data (HTTP " + bgXhr.status + ")"
                    }
                    delete root.activeBackgroundRequests[cacheKey]
                }
            }
            bgXhr.setRequestHeader("User-Agent", "plasma-reddit-feeder/1.2 (KDE Plasma 6)")
            bgXhr.send()
        }
    }

    function loadCurrentSubredditFromCache() {
        if (!root.currentSubreddit || root.currentSubreddit === "") {
            postsModel.clear()
            root.fetchError = "No subreddits configured"
            return
        }

        let cacheKey = root.currentSubreddit + "_" + (root.currentSortOrder || "hot")
        
        if (root.redditCache[cacheKey]) {
            root.isFetching = false
            root.fetchError = ""
            processRedditResponse(root.redditCache[cacheKey], true)
        } else {
            root.isFetching = true
            root.fetchError = ""
            postsModel.clear()
            
            // Trigger fetch only if isn't actively downloading
            if (!root.activeBackgroundRequests[cacheKey]) {
                fetchRedditData()
            }
        }
    }

    function fetchRedditData() {
        if (!root.currentSubreddit || root.currentSubreddit === "") {
            postsModel.clear()
            root.fetchError = "No subreddits configured"
            return
        }

        let cacheKey = root.currentSubreddit + "_" + (root.currentSortOrder || "hot")
        
        // Immediately load from cache if available to avoid waiting
        if (root.redditCache[cacheKey]) {
            processRedditResponse(root.redditCache[cacheKey], true)
        } else {
            root.isFetching = true
            root.fetchError = ""
            postsModel.clear()
        }

        if (root.currentRequest) {
            root.currentRequest.abort()
        }
        
        // Fetch new data in the background
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
                        // Update cache
                        root.redditCache[cacheKey] = text
                        processRedditResponse(text, false)
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

    function timeSince(dateValue) {
        var seconds = Math.floor((new Date() - new Date(dateValue * 1000)) / 1000);
        var interval = seconds / 31536000;
        if (interval > 1) return Math.floor(interval) + "y";
        interval = seconds / 2592000;
        if (interval > 1) return Math.floor(interval) + "mo";
        interval = seconds / 86400;
        if (interval > 1) return Math.floor(interval) + "d";
        interval = seconds / 3600;
        if (interval > 1) return Math.floor(interval) + "h";
        interval = seconds / 60;
        if (interval > 1) return Math.floor(interval) + "m";
        return Math.floor(seconds) + "s";
    }

    function formatNumberShort(num) {
        if (num >= 1000000) return (num / 1000000).toFixed(1) + "M";
        if (num >= 1000) return (num / 1000).toFixed(1) + "k";
        return num.toString();
    }

    function processRedditResponse(responseText, fromCache) {
        try {
            let json = JSON.parse(responseText)
            if (!json || !json.data || !json.data.children) {
                if (!fromCache) root.fetchError = "Invalid data format received"
                return
            }

            let posts = json.data.children

            // Clear old posts only when we have successfully parsed the new data
            postsModel.clear()

            for (let i = 0; i < posts.length; i++) {
                let child = posts[i].data
                let permalink = "https://www.reddit.com" + child.permalink
                
                let decodedTitle = decodeHtmlEntities(child.title);
                
                let thumbnailUrl = ""
                if (child.thumbnail && child.thumbnail.startsWith("http")) {
                    thumbnailUrl = decodeHtmlEntities(child.thumbnail)
                }

                postsModel.append({
                    "title": decodedTitle,
                    "author": child.author,
                    "url": permalink,
                    "thumbnail": thumbnailUrl,
                    "score": formatNumberShort(child.score || 0),
                    "num_comments": formatNumberShort(child.num_comments || 0),
                    "over_18": !!child.over_18,
                    "spoiler": !!child.spoiler,
                    "created_utc": child.created_utc ? timeSince(child.created_utc) : "",
                    "flair_text": child.link_flair_text ? decodeHtmlEntities(child.link_flair_text) : "",
                    "flair_color": child.link_flair_background_color || ""
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
