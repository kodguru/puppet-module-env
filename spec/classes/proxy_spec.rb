require 'spec_helper'

describe 'env::proxy', :type => 'class' do

  platforms = {
    'redhat' => {
      :osfamily => 'RedHat',
    },
    'suse' => {
      :osfamily => 'Suse',
    },
    'debian' => {
      :osfamily => 'Debian',
    },
    'solaris' => {
      :osfamily => 'Solaris',
    },
  }

  platforms.sort.each do |k,v|
    describe 'on supported osfamily <#{k}>' do
      let(:facts) { { :osfamily => v[:osfamily] } }
      let(:params) { { :url => 'proxy.example.com' } }

      it { should contain_class('env') }
      it { should contain_class('env::proxy') }
    end
  end

  describe 'on unsupported osfamily <CoreOS>' do
    let(:facts) { { :osfamily => 'CoreOS' } }
    let(:params) { { :url => 'proxy.example.com' } }

    it do
      expect {
        should contain_class('env::proxy')
      }.to raise_error(Puppet::Error, /env::proxy supports OS families RedHat, Suse, Debian and Solaris. Detected osfamily is <CoreOS>./)
    end
  end

  describe 'with default values for parameters on' do
    platforms.sort.each do |k,v|
      context "#{k}" do
        let(:facts) { { :osfamily => v[:osfamily] } }

        it do
          expect {
            should contain_class('env::proxy')
          }.to raise_error(Puppet::Error, /env::proxy::url is MANDATORY./)
        end
      end
    end
  end

  describe 'with profile_file_ensure param set' do
    context 'to a valid value <present>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file_ensure => 'present',
          :url                 => 'proxy.example.com'
        }
      end

      it { should contain_file('profile_d_proxy_sh') }
      it { should contain_file('profile_d_proxy_csh') }
    end

    context 'to a valid value <absent>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file_ensure => 'absent',
          :url                 => 'proxy.example.com',
        }
      end

      it do
        should contain_file('profile_d_proxy_sh').with({
          'ensure' => 'absent',
        })
      end
      it do
        should contain_file('profile_d_proxy_csh').with({
          'ensure' => 'absent',
        })
      end
    end

    context 'to an invalid value <directory>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file_ensure => 'directory',
          :url                 => 'proxy.example.com',
        }
      end

      it do
        expect {
          should contain_class('env::proxy')
        }.to raise_error(Puppet::Error, /env::proxy::profile_file_ensure is <directory>. Must be present or absent./)
      end
    end
  end

  describe 'with enable_sh and enable_csh params set' do
    platforms.sort.each do |k, v|
      context "to default on #{k}" do
        let(:facts) { { :osfamily => v[:osfamily] } }
        let(:params) { { :url => 'proxy.example.com' } }

        it do
          should contain_file('profile_d_proxy_sh').with({
            'ensure'  => 'present',
            'path'    => '/etc/profile.d/proxy.sh',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        end

        if v[:osfamily] == 'Solaris'
          it { should_not contain_file('profile_d_proxy_csh') }
        else
          it do
            should contain_file('profile_d_proxy_csh').with({
              'ensure'  => 'present',
              'path'    => '/etc/profile.d/proxy.csh',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            })
          end
        end
      end
    end

    [ 'true', false ].each do |v|
      context 'to a valid value' do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          {
            :enable_sh  => v,
            :enable_csh => v,
            :url        => 'proxy.example.com',
          }
        end

        if v
          it { should contain_file('profile_d_proxy_sh') }
          it { should contain_file('profile_d_proxy_csh') }
        end

        if not v
          it { should_not contain_file('profile_d_proxy_sh') }
          it { should_not contain_file('profile_d_proxy_csh') }
        end
      end
    end

    [ 'test', 'yessss', 'nooooo' ].each do |v|
      context "to an invalid value <#{v}>" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          {
            :enable_sh  => v,
            :enable_csh => v,
            :url        => 'proxy.example.com',
          }
        end

        it do
          expect {
            should contain_class('env::proxy')
          }.to raise_error(Puppet::Error, /str2bool\(\): Unknown type of boolean/)
        end
      end
    end

    context 'to an invalid type <string>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :url => 'proxy.example.com10' } }

      it do
        expect {
          should contain_class('env::proxy')
        }.to raise_error(Puppet::Error, /validate_fqdn\(\): "#{params[:url]}" is not a valid FQDN./)
      end
    end
  end

  describe 'with profile_file param set' do
    context 'to proxy_test' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file => 'proxy_test',
          :url          => 'proxy.example.com',
        }
      end

      it do
        should contain_file('profile_d_proxy_test_sh').with({
          'ensure'  => 'present',
          'path'    => '/etc/profile.d/proxy_test.sh',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      end

      it do
        should contain_file('profile_d_proxy_test_csh').with({
          'ensure'  => 'present',
          'path'    => '/etc/profile.d/proxy_test.csh',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      end
    end

    context 'to an invalid value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file => 'proxy_test.sh',
          :url          => 'proxy.example.com',
        }
      end

      it do
        expect {
          should contain_class('env::proxy')
        }.to raise_error(Puppet::Error, /env::proxy::profile_file must be a string and match the regex./)
      end
    end
  end

  describe 'with enable_hiera_array param set' do
    context 'to a valid value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :enable_hiera_array => true,
          :url                => 'proxy.example.com',
        }
      end

      it { should contain_class('env::proxy') }
    end

    context 'to an invalid value that is not of type array or string' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :enable_hiera_array => 10,
          :url                => 'proxy.example.com',
        }
      end

      it do
        expect {
          should contain_class('env::path')
        }.to raise_error(Puppet::Error, /env::proxy::enable_hiera_array must be of type boolean or string./)
      end
    end
  end

  describe "with url param set" do
    context 'to a valid string' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :url => 'proxy.example.com' } }

      it { should contain_file('profile_d_proxy_sh').with_content(/http_proxy=\"http:\/\/proxy.example.com:8080\"/) }
      it { should contain_file('profile_d_proxy_csh').with_content(/set proxy=\"http:\/\/proxy.example.com:8080\"/) }
    end

    [ 'true', '-1', 'proxy.example.commmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm' ].each do |url|
      context "to an invalid string <#{url}>" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) { { :url => url } }

        it do
          expect {
            should contain_class('env::proxy')
          }.to raise_error(Puppet::Error, /validate_fqdn\(\): "#{params[:url]}" is not a valid FQDN./)
        end
      end
    end
  end

  describe 'with port param set' do
    [ 8080, '9090' ].each do |port|
      context "to a valid value <#{port}>" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          {
            :url  => 'proxy.example.com',
            :port => port,
          }
        end

        it { should contain_file('profile_d_proxy_sh').with_content(/http_proxy=\"http:\/\/proxy.example.com:#{port}\"/) }
        it { should contain_file('profile_d_proxy_csh').with_content(/set proxy=\"http:\/\/proxy.example.com:#{port}\"/) }
      end
    end

    [ 0, 65536, '90900' ].each do |port|
      context "to an invalid port <#{port}>" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          {
            :url  => 'proxy.example.com',
            :port => port,
          }
        end

        it do
          expect {
            should contain_class('env::proxy')
          }.to raise_error(Puppet::Error, /validate_port\(\): #{port} is not a valid port number./)
        end
      end
    end

    [ true, 80.2 ].each do |port|
      context "to an invalid value <#{port}>" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          {
            :url  => 'proxy.example.com',
            :port => port,
          }
        end

        it do
          expect {
            should contain_class('env::proxy')
          }.to raise_error(Puppet::Error, /validate_port\(\): .?#{port}.? is not a valid port number./)
        end
      end
    end
  end

  describe 'with exceptions param set' do
    context 'to an array' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :url        => 'proxy.example.com',
          :port       => 8080,
          :exceptions => [ 'localhost', '127.0.0.1', '.example.com' ],
        }
      end

      it { should contain_file('profile_d_proxy_sh').with_content(/no_proxy=\"localhost,127.0.0.1,.example.com\"/) }
      it { should contain_file('profile_d_proxy_sh').with_content(/export .* no_proxy/) }
      it { should contain_file('profile_d_proxy_csh').with_content(/setenv no_proxy localhost,127.0.0.1,.example.com/) }
    end

    context 'to a string' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :url        => 'proxy.example.com',
          :port       => 8080,
          :exceptions => 'localhost',
        }
      end

      it do
        expect {
          should contain_class('env::proxy')
        }.to raise_error(Puppet::Error, /env::proxy::exceptions must be an array./)
      end
    end
  end
end
