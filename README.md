puppet-hbase
================
![Build Status](https://travis-ci.org/myoung34/puppet-hbase.png?branch=master,dev)&nbsp;[![Coverage Status](https://coveralls.io/repos/myoung34/puppet-hbase/badge.png)](https://coveralls.io/r/myoung34/puppet-hbase)&nbsp;[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/myoung34/puppet-hbase/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

Puppet Module For HBase

About
=====

[HBase](https://hbase.apache.org) Apache HBase is the Hadoop database, a distributed, scalable, big data store. This module is aimed at CentOS only (untested on RHEL).

Supported Versions (tested)
=================
## OS ##
* CentOS 6
    * {{version}}

Quick Start
===========

        include hbase

        class { 'hbase':
          port => '8080' # 8000 is default
        }

Hiera
=====

    hbase::port: '8080'
    
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
