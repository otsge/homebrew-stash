cask "stash-app" do
  version "0.30.0"
  sha256 "58f8245be33917ef4c0324eacdebb7ca110bf01080f451814c1e7f1dc2dd108e"

  url "https://github.com/stashapp/stash/releases/download/v#{version}/Stash.app.zip",
      verified: "github.com/stashapp/stash/"
  name "Stash"
  desc "Organizer for your porn, written in Go"
  homepage "https://stashapp.cc/"

  app "Stash.app"

  # zap trash: [
  # ]
end
