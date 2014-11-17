require 'spec_helper'

describe 'hbase' do
  context 'default parameters' do
    let(:params) {{ 
    }}
  
    let(:facts) {{
      :operatingsystem => 'RedHat',
      :osfamily => 'RedHat',
    }}

    let(:title) { 'hbase' }
  
    it { should have_class_count(6) }
    it { should contain_class('hbase::hbase') }
    it { should contain_class('hbase::params') }
    it { should contain_class('java') }

    it { should contain_yumrepo('HDP-2.1.4.0').with_enabled('1').with_gpgcheck('0').with_metadata_expire('10').with_priority('1') }
    it { should contain_yumrepo('HDP-UTILS-1.1.0.17').with_enabled('1').with_gpgcheck('0').with_metadata_expire('10').with_priority('1') }

    it { should contain_firewall('102 allow hbase').with(
      'action' => 'accept',
      'port'   => [ 8000 ],
      'proto'  => 'tcp'
    )}

    it { should contain_group('hadoop').with_ensure('present') }
    it { should contain_user('hdfs').with_ensure('present').with_home('/home/hdfs').with_managehome('true') }
    it { should contain_file('/home/hdfs').with_ensure('directory').with_group('hadoop').with_mode('0700').with_owner('hdfs').with_require('User[hdfs]') }


    it { should contain_package('hbase').with_ensure('latest').with_provider('yum').with_require('[Yumrepo[HDP-UTILS-1.1.0.17]{:name=>"HDP-UTILS-1.1.0.17"}, Yumrepo[HDP-2.1.4.0]{:name=>"HDP-2.1.4.0"}]') }
    it { should contain_file('/etc/profile.d/hbase.sh').with_replace('true').with_mode('0777').with_notify('Service[hbase]').with_owner('root').with_group('root') }
    it { should contain_exec('fix hbase JAVA_HOME').with_notify('Service[hbase]').with_require('Package[hbase]') }
    it { should contain_file('/etc/init.d/hbase').with_replace('true').with_mode('0744').with_notify('Service[hbase]').with_owner('root').with_group('root') }

    it { should contain_service('hbase').with_ensure('running') }
  
  end
end
