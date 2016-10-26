class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v0.18.2/mitmproxy-0.18.2-osx.tar.gz"
  sha256 "fbab9905bfc9919420f70a12b8ccc9e8e461d1ef9901e219d1c6140d39f9a3e5"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
