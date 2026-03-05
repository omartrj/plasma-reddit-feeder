import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "Utils.js" as Utils

PlasmoidItem {
    id: root

    property string configuredSubreddits: Plasmoid.configuration.subreddit
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
    RedditService {
        id: apiBackend
        configuredSubreddits: root.configuredSubreddits
        defaultSortOrder: root.defaultSortOrder
    }

    property alias isFetching: apiBackend.isFetching
    property alias fetchError: apiBackend.fetchError
    property alias activeSubredditList: apiBackend.activeSubredditList
    property alias currentSubreddit: apiBackend.currentSubreddit
    property alias currentSortOrder: apiBackend.currentSortOrder
    property alias postsModel: apiBackend.postsModel
    property alias lastFetchTime: apiBackend.lastFetchTime
    property alias isBackingOff: apiBackend.isBackingOff
    signal newDataAvailable()

    Connections {
        target: apiBackend
        function onNewDataAvailable() {
            root.newDataAvailable()
            refreshTimer.restart()
        }
    }

    Timer {
        id: refreshTimer
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        onTriggered: apiBackend.fetchAllSubreddits()
    }

    Component.onCompleted: {
        apiBackend.fetchAllSubreddits()
    }

    onExpandedChanged: {
        if (expanded) {
            const cacheKey = `${apiBackend.currentSubreddit}_${apiBackend.currentSortOrder || "hot"}`
            if (apiBackend.isCacheStale(cacheKey, 5)) {
                apiBackend.fetchAllSubreddits()
            }
        }
    }

    function fetchAllSubreddits() {
        apiBackend.fetchAllSubreddits()
    }

    function fetchRedditData() {
        apiBackend.fetchRedditData()
    }

    function loadCurrentSubredditFromCache() {
        apiBackend.loadCurrentSubredditFromCache()
    }


    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
