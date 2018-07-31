class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "4.0.4"
  url "https://snapshots.mitmproxy.org/#{version}/mitmproxy-#{version}-osx.tar.gz"
  sha256 "5e235c4cea420df67a1133e0c7eb7d56fac59575e93a1969823c343697333492"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
