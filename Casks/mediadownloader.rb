cask "mediadownloader" do
  version "5.4.5"
  sha256 "9cc90a2449d6bbb2a897445c2baf38bb831831906d882ea6887170dadcb160e1"

  url "https://github.com/mhogomchungu/media-downloader/releases/download/#{version}/MediaDownloaderQt6-#{version}.dmg"
  name "Media Downloader"
  desc "Qt/C++ front end to yt-dlp, youtube-dl, gallery-dl, and more"
  homepage "https://github.com/mhogomchungu/media-downloader"

  app "MediaDownloader.app"

  zap trash: [
    "~/Library/Application Support/media-downloader",
    "~/Library/Preferences/org.MediaDownloader.gui.plist",
  ]
end
