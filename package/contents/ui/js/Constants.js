.pragma library

// --- Timing ---
const BACKGROUND_REFRESH_INTERVAL_MS = 15 * 60 * 1000   // background timer between full refreshes
const STAGGER_DELAY_MS               = 2000             // delay between staggered sub fetches
const AGE_LABEL_UPDATE_INTERVAL_MS   = 60000            // how often the "updated X min ago" label ticks
const CACHE_STALE_MINUTES            = 5                // cache age threshold for on-open / sort-change fetches
const BACKOFF_DEFAULT_SECONDS        = 60               // fallback backoff if x-ratelimit-reset header is missing
const BACKOFF_MAX_SECONDS            = 600              // maximum backoff cap

// --- API ---
const REDDIT_BASE_URL = "https://www.reddit.com"
const DEFAULT_SORT    = "hot"

// --- UI: Panel sizes (in grid units) ---
const PANEL_MIN_WIDTH_GU       = 14
const PANEL_PREFERRED_WIDTH_GU = 18
const PANEL_MIN_HEIGHT_GU      = 24

// --- UI: Config page sizes (in grid units) ---
const CONFIG_PAGE_WIDTH_GU  = 25
const CONFIG_PAGE_HEIGHT_GU = 32
const CONFIG_LIST_HEIGHT_GU = 12

// --- UI: Thumbnail sizes (in grid units) ---
const THUMBNAIL_MIN_SIZE_GU = 3
const THUMBNAIL_MAX_SIZE_GU = 5

// --- UI: Opacity ---
const THUMBNAIL_OPACITY_SENSITIVE = 0.15   // NSFW / spoiler thumbnail
const OPACITY_MUTED               = 0.7    // secondary text: author, date, score, comments
const OPACITY_DISABLED            = 0.5    // placeholder text (empty state)

// --- Icons ---
const ICON_SORT      = "view-sort"
const ICON_REFRESH   = "view-refresh"
const ICON_PIN       = "window-pin"
const ICON_FEED      = "application-rss+xml"
const ICON_ERROR     = "network-disconnect"
const ICON_SCORE     = "arrow-up-double"
const ICON_COMMENTS  = "edit-comment"
const ICON_HIDDEN    = "view-hidden"
const ICON_ADD       = "list-add"
const ICON_REMOVE    = "list-remove"
const ICON_MOVE_UP   = "go-up"
const ICON_MOVE_DOWN = "go-down"
