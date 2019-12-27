class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "5.0.1"
  url "https://snapshots.mitmproxy.org/#{version}/mitmproxy-#{version}-osx.tar.gz"
  sha256 "af8e1cd463156c72b2d4ceabd9458db711d7aa8148eb354a6fee5f1b94cdc63a"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
