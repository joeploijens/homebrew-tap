class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "4.0.3"
  url "https://snapshots.mitmproxy.org/#{version}/mitmproxy-#{version}-osx.tar.gz"
  sha256 "82a6792fa45d7a9c0ee7d0ca87812f013b5367ad75fb3119f251f545b00ef45f"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
