class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "4.0.0"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v#{version}/mitmproxy-v#{version}-osx.tar.gz"
  sha256 "56212d47c85b61f9036253b262485c7f800b14931f368c54e909ce96a21e1af3"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
