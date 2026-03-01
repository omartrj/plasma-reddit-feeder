# Reddit Feeder

A lightweight and customizable Reddit feed widget for KDE Plasma 6. 

Keep up with your favorite subreddits right from your desktop, fast and distraction-free.

## Features

- **Multi-Subreddit Support**: Add multiple subreddits via settings and switch between them instantly using the top tab bar.
- **Dynamic Sorting**: Filter posts on the fly by Hot, New, Top, or Rising with a convenient dropdown menu.
- **Auto-Refresh**: Configure a custom background refresh interval to ensure your feed is always up to date.

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
