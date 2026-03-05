.pragma library

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
    const seconds = Math.floor((new Date() - new Date(dateValue * 1000)) / 1000);
    let interval = seconds / 31536000;
    if (interval > 1) return `${Math.floor(interval)}y`;
    interval = seconds / 2592000;
    if (interval > 1) return `${Math.floor(interval)}mo`;
    interval = seconds / 86400;
    if (interval > 1) return `${Math.floor(interval)}d`;
    interval = seconds / 3600;
    if (interval > 1) return `${Math.floor(interval)}h`;
    interval = seconds / 60;
    if (interval > 1) return `${Math.floor(interval)}m`;
    return `${Math.floor(seconds)}s`;
}

function formatNumberShort(num) {
    if (num >= 1000000) return `${(num / 1000000).toFixed(1)}M`;
    if (num >= 1000) return `${(num / 1000).toFixed(1)}k`;
    return num.toString();
}

function getLuminance(r, g, b) {
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function iconInstallCommand(iconSrcPath) {
    const iconName = "redditfeeder-plasmoid"
    const dest = "$HOME/.local/share/icons/hicolor/scalable/apps"
    return [
        `mkdir -p "${dest}"`,
        `[ -f '${iconSrcPath}' ]`,
        `cp '${iconSrcPath}' "${dest}/${iconName}.svg"`,
        `touch "${dest}/.."`
    ].join(" && ")
}
