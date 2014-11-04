# == Class: hadoop::platform
#
# This class installs the HDP 2.1.4 Yum repositories and sets up Java and HDFS.
#
# === Examples
#
#  class { 'hadoop::platform':
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
class hadoop::platform () {
  yumrepo { 'HDP-2.1.4.0':
    baseurl         => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.1.4.0',
    descr           => 'Hortonworks Data Platform Version - HDP-2.1.4.0',
    enabled         => 1,
    gpgcheck        => 0,
    gpgkey          => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.1.4.0/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins',
    metadata_expire => 10,
    priority        => 1,
  }->

  yumrepo { 'HDP-UTILS-1.1.0.17':
    baseurl         => 'http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.17/repos/centos6',
    descr           => 'Hortonworks Data Platform Utils Version - HDP-UTILS-1.1.0.17',
    enabled         => 1,
    gpgcheck        => 0,
    gpgkey          => 'http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.1.4.0/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins',
    metadata_expire => 10,
    priority        => 1,
  }->

  class { 'java':
    distribution => 'jre',
  }->

  group { 'hadoop':
    ensure     => present,
  }

  $created_resource_hash = create_resources_hash_from(['hdfs'])
  create_resources(hbase::hadoopuser, $created_resource_hash)
}
