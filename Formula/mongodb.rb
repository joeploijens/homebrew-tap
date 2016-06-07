require "language/go"

class Mongodb < Formula
  desc "High-performance, schema-free, document-oriented database"
  homepage "https://www.mongodb.org/"
  url "https://fastdl.mongodb.org/src/mongodb-src-r3.2.7.tar.gz"
  sha256 "cd89676af6f97561700a08b599c287fb638f14a6a1019ef9167cf55ed6a3952a"

  option "with-sasl", "Compile with SASL support"

  depends_on :macos => :yosemite
  depends_on "go" => :build
  depends_on "openssl" => :recommended
  depends_on "scons" => :build

  go_resource "github.com/mongodb/mongo-tools" do
    url "https://github.com/mongodb/mongo-tools.git",
      :tag => "r3.2.5",
      :revision => "6dab8f99eaafb764443531dc528d4b4b76eb57f2"
  end

  needs :cxx11

  def install
    # New Go tools have their own build script but the server scons "install" target is still
    # responsible for installing them.
    #Language::Go.stage_deps resources, buildpath/"src"

    # Work around an issue with the Go resource not being a Git repository after staging.
    # https://github.com/Homebrew/homebrew/issues/40136
    (buildpath/"src/github.com/mongodb").mkpath
    cd "src/github.com/mongodb" do
      system "git", "clone", "--depth", "1", "--branch", "r3.2.5", "https://github.com/mongodb/mongo-tools", "mongo-tools"
    end

    cd "src/github.com/mongodb/mongo-tools" do
      # Fix -ldflags -X syntax. As of Go 1.5 -X takes one argument instead of two
      # separate arguments. See: https://golang.org/cmd/link/
      inreplace "build.sh" do |s|
        s.gsub! "options.Gitspec ", "options.Gitspec="
        s.gsub! "options.VersionStr ", "options.VersionStr="
      end

      args = %W[]

      args << "sasl" if build.with? "sasl"

      if build.with? "openssl"
        args << "ssl"
        ENV["LIBRARY_PATH"] = Formula["openssl"].opt_lib
        ENV["CPATH"] = Formula["openssl"].opt_include
      end
      system "./build.sh", *args
    end

    mkdir "src/mongo-tools"
    cp Dir["src/github.com/mongodb/mongo-tools/bin/*"], "src/mongo-tools/"

    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --osx-version-min=#{MacOS.version}
    ]

    args << "CC=#{ENV.cc}"
    args << "CXX=#{ENV.cxx}"

    args << "--use-sasl-client" if build.with? "sasl"
    args << "--use-new-tools"
    args << "--disable-warnings-as-errors"

    if build.with? "openssl"
      args << "--ssl"
      args << "CCFLAGS=-I#{Formula["openssl"].opt_include}"
      args << "LINKFLAGS=-L#{Formula["openssl"].opt_lib}"
    end

    scons "install", *args
  end

  def post_install
    # Make sure the run-time directories exist
    %W[db/mongodb log].each { |p| (var+p).mkpath }
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
