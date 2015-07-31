class SacdExtract < Formula
  desc "Extract DSD files from an SACD image"
  homepage "https://sourceforge.net/p/sacd-ripper/"
  url "https://downloads.sf.net/project/sacd-ripper/sacd_extract_0.3.6_OS_X.zip"
  version "0.3.6"
  sha256 "e0280ab7c111efc81375449e0aee40bb6af03736b4f39095e0fdc3fa6b078b6b"

  def install
    bin.install "sacd_extract"
  end
end
