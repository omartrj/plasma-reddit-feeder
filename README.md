<div align="center">
  <h1>Reddit Feeder</h1>

  <p>
    <a href="https://www.gnu.org/licenses/gpl-3.0">
      <img alt="License: GPL v3" src="https://img.shields.io/badge/License-GPLv3-red.svg?style=flat" />
    </a>
    <a href="https://www.pling.com/p/2350142">
      <img alt="KDE Store" src="https://img.shields.io/badge/KDE%20Store-Download-1d99f3?logo=kde&style=flat" />
    </a>
    <a href="https://github.com/omartrj/plasma-reddit-feeder/stargazers">
      <img alt="GitHub stars" src="https://img.shields.io/github/stars/omartrj/plasma-reddit-feeder?color=yellow&style=flat" />
    </a>
  </p>
</div>

A lightweight and customizable Reddit feed widget for KDE Plasma 6. 

Keep up with your favorite subreddits right from your desktop, fast and distraction-free.

## Features

- **Multi-Subreddit Support**: Add multiple subreddits via settings and switch between them instantly using the top tab bar.
- **Dynamic Sorting**: Filter posts on the fly by Hot, New, Top, or Rising with a convenient dropdown menu.
- **Auto-Refresh**: Configure a custom background refresh interval to ensure your feed is always up to date.

![Desktop Mode](/assets/desktop.png)

## Installation

### From Source

You can install the widget directly using the standard `kpackagetool6`:

```bash
# Clone the repository
git clone https://github.com/your-username/plasma-reddit-feeder.git
cd plasma-reddit-feeder

# Install it for your user
kpackagetool6 -t Plasma/Applet -i package/
```

To update the widget after a `git pull`:
```bash
kpackagetool6 -t Plasma/Applet -u package/
```

## License

This project is open-source and released under the GPL-3.0 License.

## Disclaimer

This project is an independent open-source widget and is not affiliated with, authorized, maintained, sponsored, or endorsed by Reddit Inc. or any of its affiliates or subsidiaries.
