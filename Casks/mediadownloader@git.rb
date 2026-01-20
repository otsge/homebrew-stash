cask "mediadownloader@git" do
  version "5.4.7.202601202017"
  sha256 :no_check

  url "https://github.com/mhogomchungu/media-downloader-git/releases/download/0.0.0/MediaDownloaderQt6.git.dmg"
  name "Media Downloader Git"
  desc "Qt/C++ front end to yt-dlp, youtube-dl, gallery-dl, and more"
  homepage "https://github.com/mhogomchungu/media-downloader"

  livecheck do
    url :url
    regex(/Build\sversion:\s"v?(\d+[.\d]+)"/i)
    strategy :github_latest do |json, regex|
      match = json["body"]&.match(regex)
      next if match.blank?

      match[1]
    end
  end

  conflicts_with cask: "mediadownloader"

  app "MediaDownloader.app"

  zap trash: [
    "~/Library/Application Support/media-downloader",
    "~/Library/Preferences/org.MediaDownloader.gui.plist",
  ]
end
