class InstantClient < Formula
  desc "Free, light-weight client software for connecting to Oracle databases"
  homepage "https://www.oracle.com/database/technologies/instant-client.html"
  url "https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-basic-macos.x64-19.3.0.0.0dbru.zip"
  sha256 "f4335c1d53e8188a3a8cdfb97494ff87c4d0f481309284cf086dc64080a60abd"
  version "19.3.0.0.0"

  resource "sqlplus" do
    url "https://download.oracle.com/otn_software/mac/instantclient/193000/instantclient-sqlplus-macos.x64-19.3.0.0.0dbru.zip"
    sha256 "f7565c3cbf898b0a7953fbb0017c5edd9d11d1863781588b7caf3a69937a2e9e"
  end

  bottle :unneeded

  depends_on macos: :high_sierra

  def install
    buildpath.install resource("sqlplus")

    # Fix permissions
    chmod "u+w,go-w", Dir["./*"]
    chmod "u+w,a-x", Dir["*_LICENSE", "glogin.sql"]

    # Fix install names
    system "install_name_tool", "-id", "@rpath/liboramysql19.dylib", "liboramysql19.dylib"

    prefix.install Dir["*_README", "*_LICENSE]
    bin.install %W[adrci genezi uidrvci sqlplus]
    lib.install Dir["*.dylib*"]
    (prefix/"network/admin").mkpath
    (prefix/"network/admin").install "README"
    (prefix/"sqlplus/admin").mkpath
    (prefix/"sqlplus/admin").install "glogin.sql"
  end

  test do
    system bin/"sqlplus", "-V"
  end
end
