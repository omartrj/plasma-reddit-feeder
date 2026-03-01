<div align="center">
  <img src="package/contents/images/icon.svg" width="64" />
  <h1>Reddit Feeder</h1>

  <p>
    <img alt="License: GPL v3" src="https://img.shields.io/badge/License-GPLv3-brown.svg?style=flat&logo=gnu" />
    <img alt="KDE Store" src="https://img.shields.io/badge/KDE%20Store-Download-1d99f3?logo=kde&style=flat" />
    <img alt="GitHub stars" src="https://img.shields.io/github/stars/omartrj/plasma-reddit-feeder?color=red&style=flat&logo=github" />
  </p>
</div>

A lightweight and customizable Reddit feed widget for KDE Plasma 6. 

Keep up with your favorite subreddits right from your desktop, fast and distraction-free. No credentials or API keys required.

## Features

- **Multi-Subreddit Support**: Add multiple subreddits via settings and switch between them instantly using the top tab bar.
- **Dynamic Sorting**: Filter posts on the fly by Hot, New, Top, Best or Rising with a convenient dropdown menu.
- **Auto-Refresh**: Configure a custom background refresh interval to ensure your feed is always up to date.

![Desktop Mode](/assets/desktop.png)

## Installation

### 1. KDE Store (Recommended)
1. Right-click desktop > **Add widgets...**
2. Click **Get New Widgets...**
3. Search **Reddit Feeder** and install.

Or visit the [KDE Store page](https://www.pling.com/p/2350142) and click **Install** to add it directly to your desktop.

### 2. GitHub Release
Download the latest `.plasmoid` from [Releases](https://github.com/omartrj/plasma-reddit-feeder/releases) and install via terminal:
```bash
kpackagetool6 -t Plasma/Applet -i Downloads/plasma-reddit-feeder-*.plasmoid
```

### 3. From Source
```bash
git clone https://github.com/omartrj/plasma-reddit-feeder.git
cd plasma-reddit-feeder
kpackagetool6 -t Plasma/Applet -i package/
```
To update (after a git pull): `kpackagetool6 -t Plasma/Applet -u package/`

## License

This project is open-source and released under the GPL-3.0 License.

## Disclaimer

This project is an independent open-source widget and is not affiliated with, authorized, maintained, sponsored, or endorsed by Reddit Inc. or any of its affiliates or subsidiaries.
