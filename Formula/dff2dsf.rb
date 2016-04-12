class Dff2dsf < Formula
  desc "DFF to DSF command line conversion utility"
  homepage "http://www.signalyst.com/professional.html"
  url "http://www.signalyst.com/binx/dff2dsf-122.zip"
  version "1.2.2"
  sha256 "77ae7297ee1a6efe72014c7ebfd68033be40fae0246e10fc35eb7a252dd1f685"

  bottle :unneeded

  def install
    bin.install "osx/dff2dsf"
  end
end
