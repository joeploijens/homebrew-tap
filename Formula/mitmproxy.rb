class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "5.0.0"
  url "https://snapshots.mitmproxy.org/#{version}/mitmproxy-#{version}-osx.tar.gz"
  sha256 "da3c64df16705b27e852329cb3b4fc216e4239a754b0585dc8bf824e4467b449"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
