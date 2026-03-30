cask "stash-app" do
  version "0.31.0"
  sha256 "f2a87591ea983312eb0ef70a69b8ab4f2475887642d347b43de60da2bd52ed30"

  url "https://github.com/stashapp/stash/releases/download/v#{version}/Stash.app.zip",
      verified: "github.com/stashapp/stash/"
  name "Stash"
  desc "Organizer for your porn, written in Go"
  homepage "https://stashapp.cc/"

  conflicts_with cask: "stash-app@dev"

  app "Stash.app"

  # zap trash: [
  # ]
end
