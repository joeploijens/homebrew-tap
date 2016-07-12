class Mongodb < Formula
  desc "High-performance, schema-free, document-oriented database"
  homepage "https://www.mongodb.org/"
  url "https://fastdl.mongodb.org/src/mongodb-src-r3.2.8.tar.gz"
  sha256 "5501e0e90c9358358e9ee20d4814643e910b847827627ed7ca1a9d90d220c0a7"

  option "with-sasl", "Compile with SASL support"

  depends_on :macos => :yosemite
  depends_on "go" => :build
  depends_on "openssl" => :recommended
  depends_on "scons" => :build

  resource "mongo-tools" do
    url "https://github.com/mongodb/mongo-tools.git",
      :tag => "r3.2.8",
      :revision => "2214d4d6561574f962c1dc72fefce4fe11843023"
  end

  needs :cxx11

  def install
    (buildpath/"src/github.com/mongodb/mongo-tools").install resource("mongo-tools")

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
