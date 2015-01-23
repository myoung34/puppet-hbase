require 'spec_helper_acceptance'

describe 'hbase class' do
  it 'should work with defaults with no errors' do
    pp = <<-EOS
      include hbase
    EOS

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    shell("rpm -qa | grep hbase") do |result|
      assert_match /^hbase/, result.stdout, 'HBase package install was not successful.'
    end

    shell("sleep 30 && curl -s http://localhost:8000/version") do |result|
      assert_match /^rest/, result.stdout, 'HBase REST did not return a version'
    end

    shell("curl -s -X PUT 'http://localhost:8000/test/schema' -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{\"@name\":\"test\",\"ColumnSchema\":[{\"name\":\"data\"}]}'  -w '%{http_code}'") do |result|
      assert_match result.stdout, '201', 'HBase REST Master create the table.'
    end

    shell("curl -s -o /tmp/hbase_table_list.html -w '%{http_code}' http://localhost:8000") do |result|
      assert_match result.stdout, '200', 'HBase REST Master did not return a 200 OK'
    end

    shell("cat /tmp/hbase_table_list.html") do |result|
      assert_match /^test\n?$/, result.stdout, 'HBase REST Master did not return the created table.'
    end

    shell("/usr/lib/zookeeper/bin/zkCli.sh -server 127.0.0.1:2181 <<EOF | tail -n 2 | head -n 1\nls /hbase/master\nEOF") do |result|
      assert_match result.stdout, "[]\n", 'ZooKeeper does not seem to be running correctly.'
    end

  end

  it 'should allow port change' do
    pp = <<-EOS
      class { 'hbase':
        rest_port => '8080',
      }
    EOS

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    shell("sleep 30 && curl -s http://localhost:8080/version") do |result|
      assert_match /^rest/, result.stdout, 'HBase REST did not return a version'
    end

    shell("curl -s -X PUT 'http://localhost:8080/test2/schema' -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{\"@name\":\"test2\",\"ColumnSchema\":[{\"name\":\"data\"}]}'  -w '%{http_code}'") do |result|
      assert_match result.stdout, '201', 'HBase REST Master create the table.'
    end

    shell("curl -s -o /tmp/hbase_table_list2.html -w '%{http_code}' http://localhost:8080") do |result|
      assert_match result.stdout, '200', 'HBase REST Master did not return a 200 OK'
    end

    shell("cat /tmp/hbase_table_list2.html") do |result|
      assert_match /^test\ntest2\n?$/, result.stdout, 'HBase REST Master did not return the created table.'
    end

    shell("/usr/lib/zookeeper/bin/zkCli.sh -server 127.0.0.1:2181 <<EOF | tail -n 2 | head -n 1\nls /hbase/master\nEOF") do |result|
      assert_match result.stdout, "[]\n", 'ZooKeeper does not seem to be running correctly.'
    end

  end

end
