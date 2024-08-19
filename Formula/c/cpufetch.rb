class Cpufetch < Formula
  desc "CPU architecture fetching tool"
  homepage "https://github.com/Dr-Noob/cpufetch"
  url "https://github.com/Dr-Noob/cpufetch/archive/refs/tags/v1.06.tar.gz"
  sha256 "b8ec1339cf3a3bb9325cde7fb0748dd609043e8d2938c292956da7e457bdb7d9"
  license "GPL-2.0-only"
  head "https://github.com/Dr-Noob/cpufetch.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "b1fd10b7b02ae3ac52263173df652214f69d518f848f8acf2fe6702ec286fd05"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "bd1b608ca4be72a36e654d33800830b6d1c735bf1350bf2b62a8f5bc025eb777"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "0b2254b88d3cf4cbbb5fae4b9c80f2263025cec75fdfec9385dbcd2de49ea385"
    sha256 cellar: :any_skip_relocation, sonoma:         "6ff146795e24bd3e4262df01fde1ac233d9a21aa1ff48bc085294facad4e93cb"
    sha256 cellar: :any_skip_relocation, ventura:        "904d80b81bb1e327da03ef8d63053466ca20a25a642ff16844a7cbbfcb14353c"
    sha256 cellar: :any_skip_relocation, monterey:       "ebc001cff3f632df7ed4674a80e6220c65c3652118dde380173c329f3d7b7552"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c427921cffbc00a2323693c14db9f4584146bb2988e7062b84340f7292df038d"
  end

  def install
    system "make"
    bin.install "cpufetch"
    man1.install "cpufetch.1"
  end

  test do
    ephemeral_arm = ENV["HOMEBREW_GITHUB_ACTIONS"].present? &&
                    Hardware::CPU.arm? &&
                    OS.mac? &&
                    MacOS.version > :big_sur
    expected_result, line = if ephemeral_arm
      [1, 1]
    elsif OS.mac? && Hardware::CPU.intel?
      [0, 1]
    else
      [0, 0]
    end
    actual = shell_output("#{bin}/cpufetch --debug 2>&1", expected_result).lines[line].strip

    system_name = OS.mac? ? "macOS" : OS.kernel_name
    arch = (OS.mac? && Hardware::CPU.arm?) ? "ARM" : "x86 / x86_64"
    expected = "cpufetch v#{version} (#{system_name} #{arch} build)"

    assert_match expected, actual
  end
end
