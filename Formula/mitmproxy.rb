class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://snapshots.mitmproxy.org/v0.18.2/mitmproxy-0.18.2-osx.tar.gz"
  sha256 "bb5d5d1cf4bd5932aa43b0a1672141082bcbc97ec862063d0bea22be11c30d54"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
