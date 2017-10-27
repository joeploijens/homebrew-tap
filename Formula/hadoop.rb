class Hadoop < Formula
  desc "Framework for distributed processing of large data sets"
  homepage "https://hadoop.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=hadoop/common/hadoop-2.8.2/hadoop-2.8.2.tar.gz"
  mirror "https://archive.apache.org/dist/hadoop/common/hadoop-2.8.2/hadoop-2.8.2.tar.gz"
  sha256 "aea99c7ce8441749d81202bdea431f1024f17ee6e0efb3144226883207cc6292"

  bottle :unneeded

  option "without-docs", "Do not install documentation"

  depends_on :java => "1.7+"

  def install
    if build.without? "docs"
      rm_rf "share/doc"
    end

    # Remove Linux binaries and associated files
    rm_f Dir["bin/container-executor", "bin/test-container-executor", "etc/hadoop/container-executor.cfg"]

    # Remove Windows script files
    rm_f Dir["bin/*.cmd", "sbin/*.cmd", "libexec/*.cmd", "etc/hadoop/*.cmd"]
    rm_f Dir["share/hadoop/httpfs/tomcat/bin/*.bat", "share/hadoop/kms/tomcat/bin/*.bat"]

    # Duplicate
    rm_f "sbin/hdfs-config.sh"

    # Remove cruft
    rm_f Dir["share/hadoop/httpfs/tomcat/bin/*.tar.gz", "share/hadoop/kms/tomcat/bin/*.tar.gz"]
    rm_rf "share/hadoop/common/jdiff"
    rm_rf "share/hadoop/common/sources"
    rm_rf "share/hadoop/hdfs/jdiff"
    rm_rf "share/hadoop/hdfs/sources"
    rm_rf "share/hadoop/mapreduce/jdiff"
    rm_rf "share/hadoop/mapreduce/lib-examples"
    rm_rf "share/hadoop/mapreduce/sources"
    rm_rf "share/hadoop/tools/sources"
    rm_rf "share/hadoop/yarn/sources"
    rm_rf "share/hadoop/yarn/test"

    # Define the layout of Hadoop directories
    (buildpath/"libexec/hadoop-layout.sh").write <<-EOS.undent
      HADOOP_CONF_DIR=#{etc}/hadoop
      YARN_CONF_DIR=#{etc}/hadoop
      HADOOP_LOG_DIR=#{var}/log/hadoop
      HADOOP_MAPRED_LOG_DIR=#{var}/log/hadoop
      YARN_LOG_DIR=#{var}/log/hadoop
      HADOOP_PID_DIR=#{var}/run/hadoop
      HADOOP_MAPRED_PID_DIR=#{var}/run/hadoop
      YARN_PID_DIR=#{var}/run/hadoop
    EOS
    chmod 0755, buildpath/"libexec/hadoop-layout.sh"

    # Install
    libexec.install %w[bin sbin libexec share etc]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
    sbin.write_exec_script Dir["#{libexec}/sbin/*"]
    # But don't make rcc visible, it conflicts with Qt
    (bin/"rcc").unlink

    inreplace "#{libexec}/sbin/start-dfs.sh",
      "NAMENODES=$($HADOOP_PREFIX/bin/hdfs getconf -namenodes)",
      "NAMENODES=$($HADOOP_PREFIX/bin/hdfs getconf -namenodes 2>/dev/null)"
    inreplace "#{libexec}/sbin/stop-dfs.sh",
      "NAMENODES=$($HADOOP_PREFIX/bin/hdfs getconf -namenodes)",
      "NAMENODES=$($HADOOP_PREFIX/bin/hdfs getconf -namenodes 2>/dev/null)"

    inreplace "#{libexec}/etc/hadoop/hadoop-env.sh",
      "export JAVA_HOME=${JAVA_HOME}",
      "export JAVA_HOME=\"$(/usr/libexec/java_home -v 1.7+)\""
    inreplace "#{libexec}/etc/hadoop/yarn-env.sh",
      "# export JAVA_HOME=/home/y/libexec/jdk1.6.0/",
      "export JAVA_HOME=\"$(/usr/libexec/java_home -v 1.7+)\""
    inreplace "#{libexec}/etc/hadoop/mapred-env.sh",
      "# export JAVA_HOME=/home/y/libexec/jdk1.6.0/",
      "export JAVA_HOME=\"$(/usr/libexec/java_home -v 1.7+)\""
  end

  def post_install
    # Make sure runtime directories exist
    (etc/"hadoop").mkpath unless File.exist? "#{etc}/hadoop"
    (var/"hadoop/hdfs/dn").mkpath unless File.exist? "#{var}/hadoop/hdfs/dn"
    (var/"hadoop/hdfs/nn").mkpath unless File.exist? "#{var}/hadoop/hdfs/nn"
    (var/"hadoop/hdfs/snn").mkpath unless File.exist? "#{var}/hadoop/hdfs/snn"
    (var/"hadoop/yarn/local").mkpath unless File.exist? "#{var}/hadoop/yarn/local"
    (var/"hadoop/yarn/log").mkpath unless File.exist? "#{var}/hadoop/yarn/log"
    (var/"hadoop/tmp").mkpath unless File.exist? "#{var}/hadoop/tmp"
    (var/"log/hadoop").mkpath unless File.exist? "#{var}/log/hadoop"
    (var/"run/hadoop").mkpath unless File.exist? "#{var}/run/hadoop"
  end

  def caveats; <<-EOS.undent
    In Hadoop's config file:
      #{libexec}/etc/hadoop/hadoop-env.sh,
      #{libexec}/etc/hadoop/mapred-env.sh and
      #{libexec}/etc/hadoop/yarn-env.sh
    $JAVA_HOME has been set to be the output of:
      /usr/libexec/java_home
    EOS
  end
end
