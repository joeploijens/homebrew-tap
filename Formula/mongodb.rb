class Mongodb < Formula
  desc "High-performance, schema-free, document-oriented database"
  homepage "https://www.mongodb.org/"
  url "https://fastdl.mongodb.org/src/mongodb-src-r3.2.9.tar.gz"
  sha256 "25f8817762b784ce870edbeaef14141c7561eb6d7c14cd3197370c2f9790061b"

  option "with-sasl", "Compile with SASL support"

  depends_on :macos => :yosemite
  depends_on "go" => :build
  depends_on "openssl" => :recommended
  depends_on "scons" => :build

  resource "mongo-tools" do
    url "https://github.com/mongodb/mongo-tools.git",
      :tag => "r3.2.9",
      :revision => "4a4e7d30773b28cf66f75e45bc289a5d3ca49ddd"
  end

  needs :cxx11

  def install
    (buildpath/"src/github.com/mongodb/mongo-tools").install resource("mongo-tools")

    cd "src/github.com/mongodb/mongo-tools" do
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
    system bin/"mongod", "--sysinfo"
  end
end
