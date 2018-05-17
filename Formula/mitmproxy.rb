class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "4.0.1"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v#{version}/mitmproxy-v#{version}-osx.tar.gz"
  sha256 "c886bcd639cdd1593673241c366920e78347968811a14155be69672c07037daa"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
