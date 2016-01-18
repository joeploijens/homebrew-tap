class Hadoop < Formula
  desc "Framework for distributed processing of large data sets"
  homepage "https://hadoop.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=hadoop/common/hadoop-2.6.3/hadoop-2.6.3.tar.gz"
  mirror "https://archive.apache.org/dist/hadoop/common/hadoop-2.6.3/hadoop-2.6.3.tar.gz"
  sha256 "ada83d8c2ff72d4665ca2d70ce77af79bd57265beb3ce253cd2869b507e32152"

  bottle :unneeded

  depends_on :java => "1.6+"

  def install
    # Remove cruft
    rm_f Dir["bin/*.cmd", "sbin/*.cmd", "libexec/*.cmd", "etc/hadoop/*.cmd"]
    rm_f Dir["bin/container-executor", "bin/test-container-executor", "etc/hadoop/container-executor.cfg"]
    rm_f "sbin/hdfs-config.sh"
    rm_rf "share/doc"
    rm_f Dir["share/hadoop/httpfs/tomcat/bin/*.bat", "share/hadoop/httpfs/tomcat/bin/*.tar.gz"]
    rm_f Dir["share/hadoop/kms/tomcat/bin/*.bat", "share/hadoop/kms/tomcat/bin/*.tar.gz"]
    rm_rf "share/hadoop/common/jdiff"
    rm_rf "share/hadoop/common/sources"
    rm_rf "share/hadoop/common/templates"
    rm_rf "share/hadoop/hdfs/jdiff"
    rm_rf "share/hadoop/hdfs/sources"
    rm_rf "share/hadoop/hdfs/templates"
    rm_rf "share/hadoop/mapreduce/sources"
    rm_rf "share/hadoop/tools/sources"
    rm_rf "share/hadoop/yarn/sources"

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
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
    inreplace "#{libexec}/etc/hadoop/yarn-env.sh",
      "# export JAVA_HOME=/home/y/libexec/jdk1.6.0/",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
    inreplace "#{libexec}/etc/hadoop/mapred-env.sh",
      "# export JAVA_HOME=/home/y/libexec/jdk1.6.0/",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
  end

  def post_install
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
