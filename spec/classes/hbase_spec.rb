require 'spec_helper'

shared_context 'no os warning' do
  let(:facts) {{
    :operatingsystem => operating_system,
    :osfamily => os_family,
    :operatingsystemmajrelease => operating_system_major,
  }}
  it { should_not contain_exec('warn') } #no way to test for warnings.
end

shared_context 'os warning' do
  let(:facts) {{
    :operatingsystem => operating_system,
    :osfamily => os_family,
    :operatingsystemmajrelease => operating_system_major,
  }}
  it { should contain_exec('warn') } #no way to test for warnings.
end

shared_context 'hbase installation' do
  let(:facts) {{
    :operatingsystem => operating_system,
    :osfamily => os_family,
    :operatingsystemmajrelease => operating_system_major,
  }}

  it { should have_class_count(6) }
  it { should contain_class('hbase::hbase') }
  it { should contain_class('hbase::params') }
  it { should contain_class('java') }

  it { should contain_yumrepo('HDP-2.1.7.0').with_enabled('1').with_gpgcheck('0').with_metadata_expire('10').with_priority('1') }
  it { should contain_yumrepo('HDP-UTILS-1.1.0.20').with_enabled('1').with_gpgcheck('0').with_metadata_expire('10').with_priority('1') }

  it { should contain_firewall('102 allow hbase').with(
    'action' => 'accept',
    'port'   => [ rest_port, 60000, 60010, 60020, 60030 ],
    'proto'  => 'tcp'
  )}

  it { should contain_firewall('103 allow zookeeper').with(
    'action' => 'accept',
    'port'   => [ 2181 ],
    'proto'  => 'tcp'
  )}


  it { should contain_package('hbase').with_ensure('latest').with_provider('yum').with_require('[Yumrepo[HDP-UTILS-1.1.0.20]{:name=>"HDP-UTILS-1.1.0.20"}, Yumrepo[HDP-2.1.7.0]{:name=>"HDP-2.1.7.0"}]') }
  it { should contain_file('/etc/profile.d/hbase.sh').with_replace('true').with_mode('0777').with_notify('Service[hbase]').with_owner('root').with_group('root') }
  it { should contain_file('/usr/lib/hbase/conf/hbase-site.xml').with_replace('true').with_owner('hbase').with_group('hadoop').with_mode('0644') }
  it { should contain_exec('fix hbase JAVA_HOME').with_notify('Service[hbase]').with_require('Package[hbase]') }
  it { should contain_file('/etc/init.d/hbase').with_replace('true').with_mode('0744').with_notify('Service[hbase]').with_owner('root').with_group('root') }

  it { should contain_service('hbase').with_ensure('running') }
 
end

describe 'hbase' do
  context 'RedHat' do
    let(:os_family) { 'RedHat' }
    context 'Major version 6' do
      let(:operating_system_major) { '6' }

      context 'CentOS' do
        let(:operating_system) { 'CentOS' }
      
        context 'default parameters' do
          let(:rest_port) { '8000' }
       
          it_should_behave_like 'hbase installation'
        end
      
        context 'rest parameter given' do
          let(:rest_port) { '8080' }
          let(:params) {{ 
            :rest_port => rest_port
          }}
    
          it_should_behave_like 'hbase installation'
        end
        it_should_behave_like 'no os warning'
      end
  
      context 'Fedora' do
        let(:operating_system) { 'Fedora' }
      
        context 'default parameters' do
          let(:rest_port) { '8000' }
       
          it_should_behave_like 'hbase installation'
        end
      
        context 'rest parameter given' do
          let(:rest_port) { '8080' }
          let(:params) {{ 
            :rest_port => rest_port
          }}
    
          it_should_behave_like 'hbase installation'
        end
        it_should_behave_like 'os warning'
      end
  
      context 'Amazon' do
        let(:operating_system) { 'Amazon' }
      
        context 'default parameters' do
          let(:rest_port) { '8000' }
       
          it_should_behave_like 'hbase installation'
        end
      
        context 'rest parameter given' do
          let(:rest_port) { '8080' }
          let(:params) {{ 
            :rest_port => rest_port
          }}
    
          it_should_behave_like 'hbase installation'
        end
        it_should_behave_like 'os warning'
      end
    end

    context 'Unsupported major version' do
      let(:facts) {{
        :operatingsystem => 'CentOS',
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '5',
      }}
      it {
        expect {
          should contain_package('hbase')
        }.to raise_error(Puppet::Error, /RedHat major version '5' is not supported. Currently only '6' is supported\./)
      }
    end

  end

  context 'Not RedHat' do
    let(:facts) {{
      :operatingsystem => 'Bar',
      :osfamily => 'Foo',
    }}

    it {
      expect {
        should contain_package('hbase')
      }.to raise_error(Puppet::Error, /Operating system family 'Foo' is not supported\./)
    }
  end
end
