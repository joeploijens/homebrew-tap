class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "3.0.3"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v#{version}/mitmproxy-#{version}-osx.tar.gz"
  sha256 "afafb6b29f5d0569e551798ee54519795f9bb9193a43758f9df02c4d4a389792"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
