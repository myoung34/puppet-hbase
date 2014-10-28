# == Define hbase::hadoopuser
#
# This class installs the hbase master and rest servers.
#
# === Parameters
#
# [*name*]
#   The name of the user
#
# [*group*]
#   The group the user belongs to. Default is 'hadoop'
#
# [*home*]
#   The home directory for the user. Will default to '/home/{user}'
#
#
# === Examples
#
#  include hbase
#
#  class { 'hbase':
#    port => '8080' 
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
define hbase::hadoopuser (
  $name,
  $group = 'hadoop',
  $home = "/home/${name}",
) {
  user { $name:
    ensure     => present,
    allowdupe  => false,
    groups     => [
      $group,
    ],
    home       => $home,
    managehome => true,
  }

  file { $home:
    ensure  => directory,
    group   => $group,
    mode    => '0700',
    owner   => $name,
    require => User[$name],
  }
}
