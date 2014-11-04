# == Class: hbase::hbase
#
# This class installs the hbase master and rest servers.
#
# === Parameters
#
# [*port*]
#   The port to install the REST API on.
#
# === Examples
#
#  class { 'hbase::hbase':
#    port => '8080' 
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
  $port = $hbase::params::port,
) inherits hbase::params {

  firewall { '102 allow hbase':
    action => accept,
    port   => [
      $port,
    ],
    proto  => tcp,
  }->

  package { 'hbase':
    ensure   => latest,
    provider => yum,
    require  => [
      Yumrepo['HDP-UTILS-1.1.0.17'],
      Yumrepo['HDP-2.1.4.0'],
    ],
  }->

  file { '/etc/profile.d/hbase.sh':
    content => template('hbase/profile_d_hbase.sh.erb'),
    replace => true,
    mode    => '0777',
    owner   => 'root',
    group   => 'root',
  }->

  exec { 'fix hbase JAVA_HOME':
    command => 'sed -i.bak "s/export JAVA_HOME=\/usr\/java\/default//g" /usr/lib/hbase/conf/hbase-env.sh; cat /etc/zookeeper/conf/java.env >> /usr/lib/hbase/conf/hbase-env.sh',
    path    => $::path,
    require => Package['hbase'],
    onlyif  => 'grep -r "export JAVA_HOME=/usr/java/default" /usr/lib/hbase/conf/hbase-env.sh',
  }->

  file { '/etc/init.d/hbase':
    content => template('hbase/init_d_hbase.erb'),
    replace => true,
    mode    => '0744',
    owner   => 'root',
    group   => 'root',
  }->

  service { 'hbase':
    ensure => running,
  }
}
