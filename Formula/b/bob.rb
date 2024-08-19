class Bob < Formula
  desc "Version manager for neovim"
  homepage "https://github.com/MordechaiHadad/bob"
  url "https://github.com/MordechaiHadad/bob/archive/refs/tags/v4.0.0.tar.gz"
  sha256 "fbfb0e7dec49d0cadfe4ea927e9f4aa9aa9b89b77335028464cfcab0b1cfaa85"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "5d16e15838fc547b703a36379978ff583ebb7698d4232356c33d99c2a6d24627"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "3469626ca2c78b3cba3e265b8063b1309fabb65f283b75c16e83991f765b1c83"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "0f69d2a07b622ed7a5e556eec11ee221442c7b5dd3bfc735160cbbd16a6ede11"
    sha256 cellar: :any_skip_relocation, sonoma:         "19e3ceea11e597c0f9ae0d26d84c59f6cec5850e19c2c00d17df279237acd6a3"
    sha256 cellar: :any_skip_relocation, ventura:        "6dbc3ead3876a52917747b5b67c303fa8b6431e1ed4fb146d57dfe1938b44dc6"
    sha256 cellar: :any_skip_relocation, monterey:       "e6be17796a329d1afc2d01cf03d624c073bac194baa9377b5f8f470d820400ab"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d791ec895a14fea4c88c58f909b197860386a2f513c10301907f39b5d1b1420e"
  end

  depends_on "rust" => :build

  # build patch for `bob list` command
  patch do
    url "https://github.com/MordechaiHadad/bob/commit/a5c0cda1e670d983599a4b0b561fcf430bfc1359.patch?full_index=1"
    sha256 "84c2f9647f92e14eb81f9b819b0e4203f79b464341c5bfb0cd9f30d2a850495f"
  end

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"bob", "complete")
  end

  test do
    config_file = testpath/"config.json"
    config_file.write <<~EOS
      {
        "downloads_location": "#{testpath}/.local/share/bob",
        "installation_location": "#{testpath}/.local/share/bob/nvim-bin"
      }
    EOS
    ENV["BOB_CONFIG"] = config_file
    mkdir_p "#{testpath}/.local/share/bob"
    mkdir_p "#{testpath}/.local/share/nvim-bin"

    system bin/"bob", "install", "v0.9.0"
    assert_match "v0.9.0", shell_output("#{bin}/bob list")
    assert_predicate testpath/".local/share/bob/v0.9.0", :exist?
    system bin/"bob", "erase"
  end
end
