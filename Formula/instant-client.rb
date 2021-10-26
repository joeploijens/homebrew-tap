class InstantClient < Formula
  desc "Free, light-weight client software for connecting to Oracle databases"
  homepage "https://www.oracle.com/database/technologies/instant-client.html"
  url "https://download.oracle.com/otn_software/mac/instantclient/198000/instantclient-basic-macos.x64-19.8.0.0.0dbru.zip"
  sha256 "57ed4198f3a10d83cd5ddc2472c058d4c3b0b786246baebf6bbfc7391cc12087"
  version "19.8.0.0.0"

  resource "sqlplus" do
    url "https://download.oracle.com/otn_software/mac/instantclient/198000/instantclient-sqlplus-macos.x64-19.8.0.0.0dbru.zip"
    sha256 "d3cba88b0a0a3d9993c4b64b611569d146cdf36ec55dd84eba4783517bd30959"
  end

  depends_on arch: :x86_64
  depends_on macos: :high_sierra

  def install
    buildpath.install resource("sqlplus")

    # Fix permissions
    chmod "u+w,go-w", Dir["./*"]
    chmod "u+w,a-x", Dir["*_LICENSE", "glogin.sql"]

    # Fix install names
    system "install_name_tool", "-id", "@rpath/liboramysql19.dylib", "liboramysql19.dylib"

    prefix.install Dir["*_README", "*_LICENSE"]
    bin.install %W[adrci genezi uidrvci sqlplus]
    lib.install Dir["*.dylib*"]
    (prefix/"network/admin").mkpath
    (prefix/"network/admin").install "network/admin/README"
    (prefix/"sqlplus/admin").mkpath
    (prefix/"sqlplus/admin").install "glogin.sql"
  end

  test do
    system bin/"sqlplus", "-V"
  end
end
