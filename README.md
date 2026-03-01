# Reddit Feeder

A lightweight and customizable Reddit feed widget for KDE Plasma 6. 

Keep up with your favorite subreddits right from your desktop, fast and distraction-free.

## 📦 Publishing & Releases

This project includes a **GitHub Action** (`.github/workflows/release.yml`) that automatically builds your plasmoid and creates a GitHub Release whenever you push a new version tag.

### How to create a release:
1. Commit your final changes.
2. Create an annotated tag for your new version (e.g., `v1.0.0`):
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
3. GitHub Actions will automatically zip your `package/` folder into `plasma-reddit-feeder-v1.0.0.zip` and attach it to a new Release on your GitHub page.

### How to update the KDE Store:
Since the KDE Store does not currently have official programmatic upload support via GitHub Actions, use this semi-automatic approach:
1. Go to your newly created GitHub Release and right-click on the `plasma-reddit-feeder-vX.X.X.zip` asset to copy its **direct link**.
2. Go to your product page on the [KDE Store / Pling](https://store.kde.org/).
3. In the "Files" section, choose to add a file **"from URL"** and paste the GitHub Release link instead of uploading it manually from your PC.

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
