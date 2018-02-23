class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "3.0.1"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v#{version}/mitmproxy-#{version}-osx.tar.gz"
  sha256 "693a1cde741156a6e6e5c815cbe555167f070509bebacb0ee49f754080cbbd76"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
