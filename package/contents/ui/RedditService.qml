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
    property int lastFetchTime: 0   // fetch time for currently displayed subreddit (for UI)
    property bool isBackingOff: false
    property int backoffDelay: 0   // seconds, doubles on each 429 (cap: 600s)
    property var activeSubredditList: []
    property string currentSubreddit: ""
    property string currentSortOrder: ""
    property var redditCache: ({})
    property var redditCacheMeta: ({})   // per-cacheKey metadata: { fetchedAt: int }
    property var currentRequest: null
    property int staggerIndex: 0

    // Outputs
    property alias postsModel: postsModelObj
    signal newDataAvailable()

    ListModel {
        id: postsModelObj
    }

    Timer {
        id: staggerTimer
        interval: 2000
        repeat: false
        onTriggered: fetchNextStaggered()
    }

    Timer {
        id: backoffTimer
        repeat: false
        onTriggered: {
            service.isBackingOff = false
            console.log("[reddit-feeder] backoff expired, retrying fetch")
            fetchAllSubreddits()
        }
    }

    onConfiguredSubredditsChanged: updateSubredditList()
    onDefaultSortOrderChanged: {
        if (service.currentSortOrder === "") {
            service.currentSortOrder = service.defaultSortOrder
        }
    }

    function handleBackoff(resetHeader) {
        staggerTimer.stop()
        service.isFetching = false
        const resetSecs = parseInt(resetHeader) || 60
        const delaySecs = service.backoffDelay === 0
            ? resetSecs
            : Math.min(service.backoffDelay * 2, 600)
        service.backoffDelay = delaySecs
        service.isBackingOff = true
        service.fetchError = `Rate limited. Retrying in ${delaySecs}s`
        console.log(`[reddit-feeder] 429 received — backoff ${delaySecs}s`)
        backoffTimer.interval = delaySecs * 1000
        backoffTimer.restart()
    }

    function logRateLimit(xhr, source) {
        const remaining = xhr.getResponseHeader("x-ratelimit-remaining")
        const used      = xhr.getResponseHeader("x-ratelimit-used")
        const reset     = xhr.getResponseHeader("x-ratelimit-reset")
        console.log(`[reddit-feeder] [${source}] rate-limit — remaining: ${remaining}, used: ${used}, reset in: ${reset}s`)
    }

    function isCacheStale(cacheKey, maxAgeMinutes) {
        const fetchedAt = service.redditCacheMeta[cacheKey]?.fetchedAt ?? 0
        if (fetchedAt === 0) return true
        const nowSecs = Math.floor(Date.now() / 1000)
        return (nowSecs - fetchedAt) > (maxAgeMinutes * 60)
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
    }

    function fetchAllSubreddits() {
        if (!service.activeSubredditList?.length) {
            postsModelObj.clear()
            service.fetchError = "No subreddits configured"
            return
        }
        if (service.isBackingOff) {
            console.log("[reddit-feeder] fetchAllSubreddits blocked: backoff active")
            return
        }
        staggerTimer.stop()
        service.staggerIndex = 0
        fetchNextStaggered()
    }

    function fetchNextStaggered() {
        if (service.staggerIndex >= service.activeSubredditList.length) return

        const sub = service.activeSubredditList[service.staggerIndex]
        const sortMode = service.currentSortOrder || "hot"
        const cacheKey = `${sub}_${sortMode}`
        const targetUrl = `https://www.reddit.com/r/${sub}/${sortMode}.json`

        console.log(`[reddit-feeder] [stagger ${service.staggerIndex + 1}/${service.activeSubredditList.length}] GET ${targetUrl}`)

        service.staggerIndex++

        const xhr = new XMLHttpRequest()
        xhr.open("GET", targetUrl)
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE) return

            logRateLimit(xhr, `stagger r/${sub}`)

            if (xhr.status === 429) {
                handleBackoff(xhr.getResponseHeader("x-ratelimit-reset"))
                return
            }

            // Successful response: reset backoff
            service.backoffDelay = 0

            if (xhr.status === 200) {
                const newText = xhr.responseText

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
                    } catch (e) {}
                }

                service.redditCache[cacheKey] = newText
                const nowSecs = Math.floor(Date.now() / 1000)
                service.redditCacheMeta[cacheKey] = { fetchedAt: nowSecs }

                if (sub === service.currentSubreddit && sortMode === (service.currentSortOrder || "hot")) {
                    service.lastFetchTime = nowSecs
                    service.isFetching = false
                    service.fetchError = ""
                    processRedditResponse(newText, false)
                    if (isNewData) {
                        service.newDataAvailable()
                    }
                }
            } else if (sub === service.currentSubreddit && sortMode === (service.currentSortOrder || "hot")) {
                service.isFetching = false
                service.fetchError = `Failed to fetch data (HTTP ${xhr.status})`
            }

            // Schedule next stagger only after current XHR completes
            if (service.staggerIndex < service.activeSubredditList.length && !service.isBackingOff) {
                staggerTimer.restart()
            }
        }
        xhr.setRequestHeader("User-Agent", "plasma-reddit-feeder/1.2 (KDE Plasma 6)")
        xhr.send()
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
            fetchRedditData()
        }
    }

    function fetchRedditData() {
        if (!service.currentSubreddit) {
            postsModelObj.clear()
            service.fetchError = "No subreddits configured"
            return
        }
        if (service.isBackingOff) {
            console.log("[reddit-feeder] fetchRedditData blocked: backoff active")
            return
        }

        const cacheKey = `${service.currentSubreddit}_${service.currentSortOrder || "hot"}`

        // Cache-first with TTL: use cache if new (<5min), otherwise show stale cache while fetching new data
        if (service.redditCache[cacheKey] && !isCacheStale(cacheKey, 5)) {
            processRedditResponse(service.redditCache[cacheKey], true)
            return
        }

        // Cache stale or not present: show stale cache if exists, but fetch new data anyway
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
                    logRateLimit(xhr, `fetchRedditData r/${service.currentSubreddit}`)
                } catch (e) {
                    return;
                }

                if (status === 0) return;

                if (status === 429) {
                    handleBackoff(xhr.getResponseHeader("x-ratelimit-reset"))
                    return;
                }

                service.backoffDelay = 0
                service.isFetching = false
                if (status === 200) {
                    const nowSecs = Math.floor(Date.now() / 1000)
                    service.redditCache[cacheKey] = text
                    service.redditCacheMeta[cacheKey] = { fetchedAt: nowSecs }
                    service.lastFetchTime = nowSecs
                    processRedditResponse(text, false)
                } else {
                    service.fetchError = `Failed to fetch data (HTTP ${status})`
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
