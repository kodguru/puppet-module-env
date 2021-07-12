require 'spec_helper'
describe 'env::proxy', type: 'class' do
  platforms = {
    'redhat' => {
      osfamily: 'RedHat',
    },
    'suse' => {
      osfamily: 'Suse',
    },
    'debian' => {
      osfamily: 'Debian',
    },
    'solaris' => {
      osfamily: 'Solaris',
    },
  }

  platforms.sort.each do |_k, v|
    describe 'on supported osfamily <#{k}>' do
      let(:facts) { { osfamily: v[:osfamily] } }
      let(:params) { { url: 'proxy.example.com' } }

      it { is_expected.to contain_class('env') }
      it { is_expected.to contain_class('env::proxy') }
    end
  end

  describe 'on unsupported osfamily <CoreOS>' do
    let(:facts) { { osfamily: 'CoreOS' } }
    let(:params) { { url: 'proxy.example.com' } }

    it do
      expect {
        is_expected.to contain_class('env::proxy')
      }.to raise_error(Puppet::Error, %r{env::proxy supports OS families RedHat, Suse, Debian and Solaris. Detected osfamily is <CoreOS>.})
    end
  end

  describe 'with default values for parameters on' do
    platforms.sort.each do |k, v|
      context k.to_s do
        let(:facts) { { osfamily: v[:osfamily] } }

        it do
          expect {
            is_expected.to contain_class('env::proxy')
          }.to raise_error(Puppet::Error, %r{env::proxy::url is MANDATORY.})
        end
      end
    end
  end

  describe 'with profile_file_ensure param set' do
    context 'to a valid value <present>' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          profile_file_ensure: 'present',
          url:                 'proxy.example.com'
        }
      end

      it { is_expected.to contain_file('profile_d_proxy_sh') }
      it { is_expected.to contain_file('profile_d_proxy_csh') }
    end

    context 'to a valid value <absent>' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          profile_file_ensure: 'absent',
          url:                 'proxy.example.com',
        }
      end

      it { is_expected.to contain_file('profile_d_proxy_sh').with_ensure('absent') }
      it { is_expected.to contain_file('profile_d_proxy_csh').with_ensure('absent') }
    end

    context 'to an invalid value <directory>' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          profile_file_ensure: 'directory',
          url:                 'proxy.example.com',
        }
      end

      it do
        expect {
          is_expected.to contain_class('env::proxy')
        }.to raise_error(Puppet::Error, %r{env::proxy::profile_file_ensure is <directory>. Must be present or absent.})
      end
    end
  end

  describe 'with enable_sh and enable_csh params set' do
    platforms.sort.each do |k, v|
      context "to default on #{k}" do
        let(:facts) { { osfamily: v[:osfamily] } }
        let(:params) { { url: 'proxy.example.com' } }

        it do
          is_expected.to contain_file('profile_d_proxy_sh').with(
            {
              'ensure'  => 'present',
              'path'    => '/etc/profile.d/proxy.sh',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            },
          )
        end

        if v[:osfamily] == 'Solaris'
          it { is_expected.not_to contain_file('profile_d_proxy_csh') }
        else
          it do
            is_expected.to contain_file('profile_d_proxy_csh').with(
              {
                'ensure'  => 'present',
                'path'    => '/etc/profile.d/proxy.csh',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0644',
              },
            )
          end
        end
      end
    end

    [ 'true', false ].each do |v|
      context 'to a valid value' do
        let(:facts) { { osfamily: 'RedHat' } }
        let(:params) do
          {
            enable_sh:  v,
            enable_csh: v,
            url:        'proxy.example.com',
          }
        end

        if v
          it { is_expected.to contain_file('profile_d_proxy_sh') }
          it { is_expected.to contain_file('profile_d_proxy_csh') }
        end

        unless v
          it { is_expected.not_to contain_file('profile_d_proxy_sh') }
          it { is_expected.not_to contain_file('profile_d_proxy_csh') }
        end
      end
    end

    [ 'test', 'yessss', 'nooooo' ].each do |v|
      context "to an invalid value <#{v}>" do
        let(:facts) { { osfamily: 'RedHat' } }
        let(:params) do
          {
            enable_sh:  v,
            enable_csh: v,
            url:        'proxy.example.com',
          }
        end

        it do
          expect {
            is_expected.to contain_class('env::proxy')
          }.to raise_error(Puppet::Error, %r{str2bool\(\): Unknown type of boolean})
        end
      end
    end

    context 'to an invalid type <string>' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) { { url: 'proxy.example.com10' } }

      it do
        expect {
          is_expected.to contain_class('env::proxy')
        }.to raise_error(Puppet::Error, %r{validate_fqdn\(\): "#{params[:url]}" is not a valid FQDN.})
      end
    end
  end

  describe 'with profile_file param set' do
    context 'to proxy_test' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          profile_file: 'proxy_test',
          url:          'proxy.example.com',
        }
      end

      it do
        is_expected.to contain_file('profile_d_proxy_test_sh').with(
          {
            'ensure'  => 'present',
            'path'    => '/etc/profile.d/proxy_test.sh',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          },
        )
      end

      it do
        is_expected.to contain_file('profile_d_proxy_test_csh').with(
          {
            'ensure'  => 'present',
            'path'    => '/etc/profile.d/proxy_test.csh',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          },
        )
      end
    end

    context 'to an invalid value' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          profile_file: 'proxy_test.sh',
          url:          'proxy.example.com',
        }
      end

      it do
        expect {
          is_expected.to contain_class('env::proxy')
        }.to raise_error(Puppet::Error, %r{env::proxy::profile_file must be a string and match the regex.})
      end
    end
  end

  describe 'with enable_hiera_array param set' do
    context 'to a valid value' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          enable_hiera_array: true,
          url:                'proxy.example.com',
        }
      end

      it { is_expected.to contain_class('env::proxy') }
    end

    context 'to an invalid value that is not of type array or string' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          enable_hiera_array: 10,
          url:                'proxy.example.com',
        }
      end

      it do
        expect {
          is_expected.to contain_class('env::path')
        }.to raise_error(Puppet::Error, %r{env::proxy::enable_hiera_array must be of type boolean or string.})
      end
    end
  end

  describe 'with url param set' do
    context 'to a valid string' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) { { url: 'proxy.example.com' } }

      it { is_expected.to contain_file('profile_d_proxy_sh').with_content(%r{http_proxy=\"http:\/\/proxy.example.com:8080\"}) }
      it { is_expected.to contain_file('profile_d_proxy_csh').with_content(%r{set proxy=\"http:\/\/proxy.example.com:8080\"}) }
    end

    [ 'true', '-1', 'proxy.example.commmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm' ].each do |url|
      context "to an invalid string <#{url}>" do
        let(:facts) { { osfamily: 'RedHat' } }
        let(:params) { { url: url } }

        it do
          expect {
            is_expected.to contain_class('env::proxy')
          }.to raise_error(Puppet::Error, %r{validate_fqdn\(\): "#{params[:url]}" is not a valid FQDN.})
        end
      end
    end
  end

  describe 'with port param set' do
    [ 8080, '9090' ].each do |port|
      context "to a valid value <#{port}>" do
        let(:facts) { { osfamily: 'RedHat' } }
        let(:params) do
          {
            url:  'proxy.example.com',
            port: port,
          }
        end

        it { is_expected.to contain_file('profile_d_proxy_sh').with_content(%r{http_proxy=\"http:\/\/proxy.example.com:#{port}\"}) }
        it { is_expected.to contain_file('profile_d_proxy_csh').with_content(%r{set proxy=\"http:\/\/proxy.example.com:#{port}\"}) }
      end
    end

    [ 0, 65_536, '90900' ].each do |port|
      context "to an invalid port <#{port}>" do
        let(:facts) { { osfamily: 'RedHat' } }
        let(:params) do
          {
            url:  'proxy.example.com',
            port: port,
          }
        end

        it do
          expect {
            is_expected.to contain_class('env::proxy')
          }.to raise_error(Puppet::Error, %r{validate_port\(\): #{port} is not a valid port number.})
        end
      end
    end

    [ true, 80.2 ].each do |port|
      context "to an invalid value <#{port}>" do
        let(:facts) { { osfamily: 'RedHat' } }
        let(:params) do
          {
            url:  'proxy.example.com',
            port: port,
          }
        end

        it do
          expect {
            is_expected.to contain_class('env::proxy')
          }.to raise_error(Puppet::Error, %r{validate_port\(\): .?#{port}.? is not a valid port number.})
        end
      end
    end
  end

  describe 'with exceptions param set' do
    context 'to an array' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          url:        'proxy.example.com',
          port:       8080,
          exceptions: [ 'localhost', '127.0.0.1', '.example.com' ],
        }
      end

      it { is_expected.to contain_file('profile_d_proxy_sh').with_content(%r{no_proxy=\"localhost,127.0.0.1,.example.com\"}) }
      it { is_expected.to contain_file('profile_d_proxy_sh').with_content(%r{export .* no_proxy}) }
      it { is_expected.to contain_file('profile_d_proxy_csh').with_content(%r{setenv no_proxy localhost,127.0.0.1,.example.com}) }
    end

    context 'to a string' do
      let(:facts) { { osfamily: 'RedHat' } }
      let(:params) do
        {
          url:        'proxy.example.com',
          port:       8080,
          exceptions: 'localhost',
        }
      end

      it do
        expect {
          is_expected.to contain_class('env::proxy')
        }.to raise_error(Puppet::Error, %r{env::proxy::exceptions must be an array.})
      end
    end
  end
end
