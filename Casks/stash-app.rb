cask "stash-app" do
  version "0.31.1"
  sha256 "f132d50b2b76d77ab066d513685bde16760d15ab1e98aae5a885a28a451b80e9"

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
