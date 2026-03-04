import QtQuick
import "Utils.js" as Utils

Item {
    id: service

    // Inputs
    property string configuredSubreddits: ""
    property string defaultSortOrder: "hot"

    // State
    property bool isFetching: false
    property string fetchError: ""
    property int lastFetchTime: 0
    property var activeSubredditList: []
    property string currentSubreddit: ""
    property string currentSortOrder: ""
    property var redditCache: ({})
    property var activeBackgroundRequests: ({})
    property var currentRequest: null

    // Outputs
    property alias postsModel: postsModelObj
    signal newDataAvailable()

    ListModel {
        id: postsModelObj
    }

    onConfiguredSubredditsChanged: updateSubredditList()
    onDefaultSortOrderChanged: {
        if (service.currentSortOrder === "") {
            service.currentSortOrder = service.defaultSortOrder
        }
    }

    function isCacheStale(maxAgeMinutes) {
        if (service.lastFetchTime === 0) return true
        const nowSecs = Math.floor(Date.now() / 1000)
        return (nowSecs - service.lastFetchTime) > (maxAgeMinutes * 60)
    }

    function parseConfiguredSubreddits(subsString) {
        return subsString.split('+').map(s => s.trim()).filter(s => s !== "")
    }

    function updateSubredditList() {
        service.activeSubredditList = parseConfiguredSubreddits(service.configuredSubreddits)

        if (service.activeSubredditList.length > 0) {
            if (!service.activeSubredditList.includes(service.currentSubreddit)) {
                service.currentSubreddit = service.activeSubredditList[0]
            }
        } else {
            service.currentSubreddit = ""
        }
        
        fetchAllSubreddits()
    }

    function fetchAllSubreddits() {
        if (!service.activeSubredditList?.length) return
        
        const sortMode = service.currentSortOrder || "hot"
        
        for (const sub of service.activeSubredditList) {
            const cacheKey = `${sub}_${sortMode}`
            
            const bgXhr = new XMLHttpRequest()
            service.activeBackgroundRequests[cacheKey] = bgXhr
            
            const targetUrl = `https://www.reddit.com/r/${sub}/${sortMode}.json`
            
            bgXhr.open("GET", targetUrl)
            bgXhr.onreadystatechange = () => {
                if (bgXhr.readyState === XMLHttpRequest.DONE) {
                    if (bgXhr.status === 200) {
                        const newText = bgXhr.responseText
                        
                        let isNewData = true
                        if (service.redditCache[cacheKey]) {
                            try {
                                const oldJson = JSON.parse(service.redditCache[cacheKey])
                                const newJson = JSON.parse(newText)
                                const oldFirstId = oldJson?.data?.children?.[0]?.data?.id
                                const newFirstId = newJson?.data?.children?.[0]?.data?.id
                                
                                if (oldFirstId && newFirstId && oldFirstId === newFirstId) {
                                    isNewData = false
                                }
                            } catch (e) {
                                // Fallback: if parsing fails, assume it's new data
                            }
                        }
                        
                        service.redditCache[cacheKey] = newText
                        
                        service.lastFetchTime = Math.floor(Date.now() / 1000)

                        if (sub === service.currentSubreddit && sortMode === (service.currentSortOrder || "hot")) {
                            service.isFetching = false
                            service.fetchError = ""
                            processRedditResponse(newText, false)
                            // Notify the UI to scroll ONLY if the background fetch found a new topmost post
                            if (isNewData) {
                                service.newDataAvailable()
                            }
                        }
                    } else if (sub === service.currentSubreddit && sortMode === (service.currentSortOrder || "hot")) {
                        service.isFetching = false
                        service.fetchError = `Failed to fetch data (HTTP ${bgXhr.status})`
                    }
                    delete service.activeBackgroundRequests[cacheKey]
                }
            }
            bgXhr.setRequestHeader("User-Agent", "plasma-reddit-feeder/1.2 (KDE Plasma 6)")
            bgXhr.send()
        }
    }

    function loadCurrentSubredditFromCache() {
        if (!service.currentSubreddit) {
            postsModelObj.clear()
            service.fetchError = "No subreddits configured"
            return
        }

        const cacheKey = `${service.currentSubreddit}_${service.currentSortOrder || "hot"}`
        
        if (service.redditCache[cacheKey]) {
            service.isFetching = false
            service.fetchError = ""
            processRedditResponse(service.redditCache[cacheKey], true)
        } else {
            service.isFetching = true
            service.fetchError = ""
            postsModelObj.clear()
            
            if (!service.activeBackgroundRequests[cacheKey]) {
                fetchRedditData()
            }
        }
    }

    function fetchRedditData() {
        if (!service.currentSubreddit) {
            postsModelObj.clear()
            service.fetchError = "No subreddits configured"
            return
        }

        const cacheKey = `${service.currentSubreddit}_${service.currentSortOrder || "hot"}`
        
        if (service.redditCache[cacheKey]) {
            processRedditResponse(service.redditCache[cacheKey], true)
        } else {
            service.isFetching = true
            service.fetchError = ""
            postsModelObj.clear()
        }

        if (service.currentRequest) {
            service.currentRequest.abort()
        }
        
        const xhr = new XMLHttpRequest()
        service.currentRequest = xhr
        const targetUrl = `https://www.reddit.com/r/${service.currentSubreddit}/${service.currentSortOrder || "hot"}.json`
        
        xhr.open("GET", targetUrl)
        xhr.onreadystatechange = () => {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (service.currentRequest === xhr) {
                    service.currentRequest = null
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
                    if (status === 0) {
                        return;
                    }
                    service.isFetching = false
                    if (status === 200) {
                        service.lastFetchTime = Math.floor(Date.now() / 1000)
                        service.redditCache[cacheKey] = text
                        processRedditResponse(text, false)
                    } else {
                        service.fetchError = `Failed to fetch data (HTTP ${status})`
                    }
                } catch (e) {
                }
            }
        }
        xhr.setRequestHeader("User-Agent", "plasma-reddit-feeder/1.2 (KDE Plasma 6)")
        xhr.send()
    }

    function processRedditResponse(responseText, fromCache) {
        try {
            const json = JSON.parse(responseText)
            if (!json?.data?.children) {
                if (!fromCache) service.fetchError = "Invalid data format received"
                return
            }

            const posts = json.data.children

            postsModelObj.clear()

            for (const item of posts) {
                const child = item.data
                const permalink = `https://www.reddit.com${child.permalink}`
                
                const decodedTitle = Utils.decodeHtmlEntities(child.title);
                
                let thumbnailUrl = ""
                if (child.thumbnail?.startsWith("http")) {
                    thumbnailUrl = Utils.decodeHtmlEntities(child.thumbnail)
                }

                postsModelObj.append({
                    "title": decodedTitle,
                    "author": child.author,
                    "url": permalink,
                    "thumbnail": thumbnailUrl,
                    "score": Utils.formatNumberShort(child.score ?? 0),
                    "num_comments": Utils.formatNumberShort(child.num_comments ?? 0),
                    "over_18": !!child.over_18,
                    "spoiler": !!child.spoiler,
                    "created_utc": child.created_utc ? Utils.timeSince(child.created_utc) : "",
                    "flair_text": child.link_flair_text ? Utils.decodeHtmlEntities(child.link_flair_text) : "",
                    "flair_color": child.link_flair_background_color || ""
                })
            }
        } catch (e) {
            service.fetchError = `Error parsing response: ${e.toString()}`
            postsModelObj.clear()
        }
    }
}
