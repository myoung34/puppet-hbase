# == Class: hbase::hbase
#
# This class installs the hbase master and rest servers.
#
# === Parameters
#
# [*rest_port*]
#   The port to install the REST API on.
#
# === Examples
#
#  class { 'hbase::hbase':
#    rest_port => '8080' 
#  }
#
#  class { 'hbase::hbase':
#  }
#
# === Authors
#
# Marcus Young <myoung34@my.apsu.edu>
#
# === Copyright
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Marcus Young
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.
#
class hbase::hbase (
  $rest_port = $hbase::params::rest_port,
) inherits hbase::params {
  if ($::osfamily !~ /RedHat/) {
    fail("Operating system family '${osfamily}' is not supported.")
  }
  if ($::operatingsystem != 'CentOS') {
    warning("This has not been tested on '${operatingsystem}'.")

    #there is currently no way to test for warnings.
    exec { 'warn':
      command => 'touch /tmp/hbase-puppet-warning',
      path    => $::path,
      creates => '/tmp/hbase-puppet-warning',
    }
  }

  if $::operatingsystemmajrelease {
    $os_maj_release = $::operatingsystemmajrelease
  } else {
    $os_versions    = split($::operatingsystemrelease, '[.]')
    $os_maj_release = $os_versions[0]
  }
  if ($os_maj_release != "6") {
    fail("RedHat major version '${os_maj_release}' is not supported. Currently only '6' is supported.")
  }

  yumrepo { 'HDP-2.1.7.0':
    baseurl         => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.1.7.0',
    descr           => 'Hortonworks Data Platform Version - HDP-2.1.7.0',
    enabled         => 1,
    gpgcheck        => 0,
    metadata_expire => 10,
    priority        => 1,
  }->

  yumrepo { 'HDP-UTILS-1.1.0.20':
    baseurl         => 'http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.20/repos/centos6',
    descr           => 'Hortonworks Data Platform Utils Version - HDP-UTILS-1.1.0.20',
    enabled         => 1,
    gpgcheck        => 0,
    metadata_expire => 10,
    priority        => 1,
  }->

  firewall { '102 allow hbase':
    action => accept,
    port   => [ $rest_port, 60000, 60010, 60020, 60030 ],
    proto  => tcp,
  }->

  firewall { '103 allow zookeeper':
    action => accept,
    port   => [ 2181 ],
    proto  => tcp,
  }->

  class { 'java':
    distribution => 'jre',
  }->

  group { 'hadoop':
    ensure     => present,
  }

  package { 'hbase':
    ensure   => latest,
    notify   => Service['hbase'],
    provider => yum,
    require  => [
      Yumrepo['HDP-UTILS-1.1.0.17'],
      Yumrepo['HDP-2.1.4.0'],
    ],
  }->

  file { '/etc/profile.d/hbase.sh':
    content => template('hbase/profile_d_hbase.sh.erb'),
    group   => 'root',
    mode    => '0777',
    notify  => Service['hbase'],
    owner   => 'root',
    replace => true,
  }->

  exec { 'fix hbase JAVA_HOME':
    command => 'sed -i.bak "s/export JAVA_HOME=\/usr\/java\/default//g" /usr/lib/hbase/conf/hbase-env.sh; cat /etc/zookeeper/conf/java.env >> /usr/lib/hbase/conf/hbase-env.sh',
    notify  => Service['hbase'],
    onlyif  => 'grep -r "export JAVA_HOME=/usr/java/default" /usr/lib/hbase/conf/hbase-env.sh',
    path    => $::path,
    require => Package['hbase'],
  }->

  file { '/usr/lib/hbase/conf/hbase-site.xml':
      content => template('hbase/configuration-hbase-site.xml.erb'),
      group   => 'hadoop',
      mode    => '0644',
      owner   => 'hbase',
      replace => true,
  }->

  file { '/etc/init.d/hbase':
    content => template('hbase/init_d_hbase.erb'),
    group   => 'root',
    mode    => '0744',
    notify  => Service['hbase'],
    owner   => 'root',
    replace => true,
  }->

  service { 'hbase':
    ensure => running,
  }
}
