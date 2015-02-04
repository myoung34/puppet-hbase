puppet-hbase
================
![Build Status](https://travis-ci.org/myoung34/puppet-hbase.png?branch=master,dev)&nbsp;
[![Coverage Status](https://coveralls.io/repos/myoung34/puppet-hbase/badge.png)](https://coveralls.io/r/myoung34/puppet-hbase)&nbsp;
[![Puppet Forge](https://img.shields.io/puppetforge/v/myoung34/hbase.svg)](https://forge.puppetlabs.com/myoung34/hbase)
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/myoung34/puppet-hbase/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

Puppet Module For HBase

About
=====

[HBase](https://hbase.apache.org) Apache HBase is the Hadoop database, a distributed, scalable, big data store. This module is aimed at CentOS only (untested on RHEL).
This module starts the HBase master and REST API with built-in zookeeper.

Supported Versions (tested)
=================
## OS ##
* CentOS 6
    * hbase-0.98.0.2.1.3.0

Quick Start
===========

        include hbase

        class { 'hbase':
          rest_port => '8080' # 8000 is default
        }

Hiera
=====

    hbase::rest_port: '8080'

Testing
=====

* Run the default tests (puppet + lint)

        bundle install
        bundle exec rake

* Run the [beaker](https://github.com/puppetlabs/beaker) acceptance tests

        $ bundle exec rake acceptance

Submitting pull requests
========================

I use the the gitflow model.
 * Features should be created with a 'feature' prefix, such as 'feature/add-something'.
 * Bugs should be created in a branch with a 'bugfix' prefix, such as 'bugfix/issue-4' or 'bugfix/timing-issue'.

Verify tests pass, then submit a pull request and make sure your branch has been rebased against my default branch (master).
