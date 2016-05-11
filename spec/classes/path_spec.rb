require 'spec_helper'

describe 'env::path', :type => 'class' do

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
      let(:params) { { :directories => [ '$HOME/bin' ] } }

      it { should contain_class('env') }
      it { should contain_class('env::path') }
    end
  end

  describe 'on unsupported osfamily <CoreOS>' do
    let(:facts) { { :osfamily => 'CoreOS' } }
    let(:params) { { :directories => [ '$HOME/bin' ] } }

    it do
      expect {
        should contain_class('env::path')
      }.to raise_error(Puppet::Error, /env::path supports OS families RedHat, Suse, Debian and Solaris. Detected osfamily is <CoreOS>./)
    end
  end

  describe 'with default values for parameters on' do
    platforms.sort.each do |k,v|
      context "#{k}" do
        let(:facts) { { :osfamily => v[:osfamily] } }

        it do
          expect {
            should contain_class('env::path')
          }.to raise_error(Puppet::Error, /env::path::directories is MANDATORY./)
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
          :directories         => [ '$HOME/bin' ],
        }
      end

      it { should contain_file('profile_d_path_sh') }
      it { should contain_file('profile_d_path_csh') }
    end

    context 'to a valid value <absent>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file_ensure => 'absent',
          :directories         => [ '$HOME/bin' ],
        }
      end

      it do
        should contain_file('profile_d_path_sh').with({
          'ensure' => 'absent',
        })
      end
      it do
        should contain_file('profile_d_path_csh').with({
          'ensure' => 'absent',
        })
      end
    end

    context 'to an invalid value <directory>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file_ensure => 'directory',
          :directories         => [ '$HOME/bin' ],
        }
      end

      it do
        expect {
          should contain_class('env')
        }.to raise_error(Puppet::Error, /env::path::profile_file_ensure is <directory>. Must be present or absent./)
      end
    end
  end

  describe 'with enable_sh and enable_csh params set' do
    platforms.sort.each do |k,v|
      context "to default on #{k}" do
        let(:facts) { { :osfamily => v[:osfamily] } }
        let(:params) { { :directories => [ '$HOME/bin' ] } }

        it do
          should contain_file('profile_d_path_sh').with({
            'ensure'  => 'present',
            'path'    => '/etc/profile.d/path.sh',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        end

        if v[:osfamily] == 'Solaris'
          it { should_not contain_file('profile_d_path_csh') }
        else
          it do
            should contain_file('profile_d_path_csh').with({
              'ensure'  => 'present',
              'path'    => '/etc/profile.d/path.csh',
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
            :enable_sh   => v,
            :enable_csh  => v,
            :directories => [ '$HOME/bin' ],
          }
        end

        if v
          it { should contain_file('profile_d_path_sh') }
          it { should contain_file('profile_d_path_csh') }
        end

        if not v
          it { should_not contain_file('profile_d_path_sh') }
          it { should_not contain_file('profile_d_path_csh') }
        end
      end
    end

    [ 'test', 'yessss', 'nooooo' ].each do |v|
      context "to an invalid value <#{v}>" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          {
            :enable_sh   => v,
            :enable_csh  => v,
            :directories => [ '$HOME/bin' ],
          }
        end

        it do
          expect {
            should contain_class('env::path')
          }.to raise_error(Puppet::Error, /str2bool\(\): Unknown type of boolean/)
        end
      end
    end

    context 'to an invalid type <string>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :directories => '$HOME/bin' } }

      it do
        expect {
          should contain_class('env::path')
        }.to raise_error(Puppet::Error, /env::path::directories must be an array./)
      end
    end
  end

  describe 'with enable_hiera_array param set' do
    context 'to an invalid value that is not of type array or string' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :enable_hiera_array => 10,
          :directories        => [ '$HOME/bin' ],
        }
      end

      it do
        expect {
          should contain_class('env::path')
        }.to raise_error(Puppet::Error, /env::path::enable_hiera_array must be of type boolean or string./)
      end
    end
  end

  describe 'with include_existing_path param set' do
    context 'to a valid value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :include_existing_path => true,
          :directories           => [ '$HOME/bin' ],
        }
      end

      it { should contain_class('env::path') }
    end

    context 'to an invalid value that is not of type array or string' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :include_existing_path => 10,
          :directories           => [ '$HOME/bin' ],
        }
      end

      it do
        expect {
          should contain_class('env::path')
        }.to raise_error(Puppet::Error, /env::path::include_existing_path must be of type boolean or string./)
      end
    end

    context 'to an invalid value of type <string>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :include_existing_path => 'test',
          :directories           => [ '$HOME/bin' ],
        }
      end

      it do
        expect {
          should contain_class('env::path')
        }.to raise_error(Puppet::Error, /str2bool\(\): Unknown type of boolean/)
      end
    end
  end

  describe 'with directories param set' do
    context 'to an array with single index' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :directories => [ '$HOME/bin' ] } }

      it { should contain_file('profile_d_path_sh').with_content(/PATH\=\$\{PATH\}:\$HOME\/bin/) }
      it { should contain_file('profile_d_path_csh').with_content(/set path \= \(\$path \$HOME\/bin\)/) }
    end

    context 'to an array with multiple indexes' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :directories => [ '$HOME/bin', '/opt/bin' ] } }

      it { should contain_file('profile_d_path_sh').with_content(/PATH\=\$\{PATH\}:\$HOME\/bin:\/opt\/bin/) }
      it { should contain_file('profile_d_path_csh').with_content(/set path \= \(\$path \$HOME\/bin\ \/opt\/bin\)/) }
    end

    context 'to an invalid type <string>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :directories => '$HOME/bin' } }

      it do
        expect {
          should contain_class('env::path')
        }.to raise_error(Puppet::Error, /env::path::directories must be an array./)
      end
    end
  end

  describe 'with profile_file param set' do
    context 'to path_test' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file => 'path_test',
          :directories  => [ '$HOME/bin' ],
        }
      end

      it do
        should contain_file('profile_d_path_test_sh').with({
          'ensure'  => 'present',
          'path'    => '/etc/profile.d/path_test.sh',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      end

      it do
        should contain_file('profile_d_path_test_csh').with({
          'ensure'  => 'present',
          'path'    => '/etc/profile.d/path_test.csh',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      end
    end

    context 'to an invalid' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file => 'path_test.sh',
          :directories  => [ '$HOME/bin' ],
        }
      end

      it do
        expect {
          should contain_class('env::path')
        }.to raise_error(Puppet::Error, /env::path::profile_file must be a string and match the regex./)
      end
    end
  end
end
