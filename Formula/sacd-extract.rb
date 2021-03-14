class SacdExtract < Formula
  desc "Extract DSD files from an SACD image"
  homepage "https://github.com/sacd-ripper/sacd-ripper/"
  url "https://github.com/sacd-ripper/sacd-ripper/archive/0.3.8.tar.gz"
  sha256 "8c65c5fa518cb2c9d7c7221b6cd322ef1553341c6eb47bc670979e0eb7cefcce"

  depends_on arch: :x86_64
  depends_on "cmake" => :build

  def install
    cd "tools/sacd_extract"
    system "cmake", "."
    system "make"
    bin.install "sacd_extract"
  end

  test do
    system bin/"sacd_extract", "--help"
  end
end
