import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "Utils.js" as Utils

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
    signal newDataAvailable()

    Connections {
        target: apiBackend
        function onNewDataAvailable() {
            root.newDataAvailable()
        }
    }

    Timer {
        id: refreshTimer
        interval: root.refreshInterval * 60 * 1000
        running: true
        repeat: true
        onTriggered: {
            apiBackend.fetchAllSubreddits()
        }
    }

    onExpandedChanged: {
        if (expanded) {
            apiBackend.fetchAllSubreddits()
            refreshTimer.restart()
        }
    }

    onRefreshIntervalChanged: refreshTimer.restart()

    function fetchRedditData() {
        apiBackend.fetchRedditData()
        refreshTimer.restart()
    }

    function loadCurrentSubredditFromCache() {
        apiBackend.loadCurrentSubredditFromCache()
        refreshTimer.restart()
    }


    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
