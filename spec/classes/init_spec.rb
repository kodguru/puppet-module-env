require 'spec_helper'

describe 'env', :type => 'class' do

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

  describe 'with default values for parameters on' do
    platforms.sort.each do |k,v|
      context "#{k}" do
        let(:facts) { { :osfamily => v[:osfamily] } }

        it { should compile.with_all_deps }

        it { should contain_class('env') }

        if v[:osfamily] == 'Solaris'
          it do
            should contain_file('profile_d').with({
              'ensure' => 'directory',
              'path'   => '/etc/profile.d',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0755',
            })
          end

          it do
            should contain_exec('etc_profile').with({
              'command'   => 'echo "\n#Puppet: Do not removed\nif [ -d /etc/profile.d ]; then\n\tfor i in /etc/profile.d/*.sh; do\n\t\tif [ -r \$i ]; then\n\t\t\t. \$i\n\t\tfi\n\tdone\n\tunset i\nfi\n" >> /etc/profile',
              'unless'    => 'grep "if \[ \-d \/etc\/profile\.d \]; then" /etc/profile',
              'path'      => [ '/usr/bin', '/usr/sbin' ],
            })
          end

          it { should contain_exec('etc_profile').that_requires('File[profile_d]') }
        else
          it { should_not contain_exec('etc_profile') }
          it { should_not contain_file('profile_d') }
        end

        it { should_not contain_file('profile_d__sh') }
        it { should_not contain_file('profile_d__csh') }
      end
    end
  end

  describe 'with profile_file_ensure param set' do
    context 'to a valid value <present>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file_ensure => 'present',
          :profile_file        => 'test',
        }
      end

      it { should_not contain_file('profile_d_test_sh') }
      it { should_not contain_file('profile_d_test_csh') }
    end

    context 'to an invalid value <directory>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file_ensure => 'directory',
          :profile_file        => 'test',
        }
      end

      it do
        expect {
          should contain_class('env')
        }.to raise_error(Puppet::Error, /env::profile_file_ensure is <directory>. Must be present or absent./)
      end
    end
  end

  describe 'with profile_file param set' do
    context 'to a valid value <test>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :profile_file => 'test' } }

      it { should_not contain_file('profile_d_test_sh') }
      it { should_not contain_file('profile_d_test_csh') }
    end

    context 'to an invalid value <test.sh>' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :profile_file => 'test.sh' } }

      it do
        expect {
          should contain_class('env')
        }.to raise_error(Puppet::Error, /env::profile_file must be a string and match the regex./)
      end
    end
  end

  describe 'with param content_sh set' do
    context 'to a valid value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file => 'test',
          :content_sh   => 'echo "test"',
        }
      end

      it do
        should contain_file('profile_d_test_sh').with({
          'ensure'  => 'present',
          'path'    => '/etc/profile.d/test.sh',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => 'echo "test"',
        })
      end

      it { should_not contain_file('profile_d_test_csh') }
    end

    context 'to an invalid value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file => 'test',
          :content_sh   => [ 'echo "test"' ],
        }
      end

      it do
        expect {
          should contain_class('env')
        }.to raise_error(Puppet::Error, /env::content_sh must be a string./)
      end
    end
  end

  describe 'with param content_csh set' do
    context 'to a valid value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file => 'test',
          :content_csh  => 'echo "test"',
        }
      end

      it do
        should contain_file('profile_d_test_csh').with({
          'ensure'  => 'present',
          'path'    => '/etc/profile.d/test.csh',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => 'echo "test"',
        })
      end

      it { should_not contain_file('profile_d_test_sh') }
    end

    context 'to an invalid value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        {
          :profile_file => 'test',
          :content_csh   => [ 'echo "test"' ],
        }
      end

      it do
        expect {
          should contain_class('env')
        }.to raise_error(Puppet::Error, /env::content_csh must be a string./)
      end
    end
  end
end
