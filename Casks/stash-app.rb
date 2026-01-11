cask "stash-app" do
  version "0.30.1"
  sha256 "43325033ae8882ad6921591ac3b69f69b6b9c7a50e41c0368963f7f133afda2b"

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
