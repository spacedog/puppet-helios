require 'spec_helper'

describe "helios::install" do
  let (:facts) {
    {
      :fqdn            => 'test.example.com',
      :hostname        => 'test',
      :ipaddress       => '192.168.0.1',
      :operatingsystem => 'CentOS',
      :osfamily        => 'RedHat'
    }
  }

  let (:default_params) {
    {
      'ensure'           => 'present',
      'repo_url'         => 'https://github.com/benadida/helios-server.git',
      'repo_ref'         => 'f5dc954c12eacbeb221646511e47537307a941aa',
      'base_dir'         => '/opt/helios-web',
      'helios_web_user'  => 'helios',
      'helios_web_group' => 'helios',
    }
  }

  context 'with defaults for all parameters' do
    let (:params) {{}}

    it do
      expect {
        should compile
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
     /Must pass /)
    end
  end

  context 'with basic init defaults' do

    let (:params) {
      default_params.merge({
        :db_engine => 'mysql',
      })
    }

    it do
      should contain_class('helios::install')
      should contain_class('python').with({
        :virtualenv => true,
        :dev        => true,
        :pip        => true,
      })
      should contain_file('/opt/helios-web').with({
        :ensure => 'directory',
        :owner  => 'helios',
        :group  => 'helios',
        :mode   => '0755',
      })
      should contain_package('MySQL-python')
      should contain_vcsrepo('/opt/helios-web/helios').with ({
        :ensure   => 'present',
        :owner    => 'helios',
        :group    => 'helios',
        :provider => 'git',
        :source   => 'https://github.com/benadida/helios-server.git',
        :revision => 'f5dc954c12eacbeb221646511e47537307a941aa',
      })
      should contain_python__virtualenv('/opt/helios-web/virtualenv').with({
        :ensure       => 'present',
        :version      => 'system',
        :systempkgs   => true,
        :requirements => '/opt/helios-web/helios/requirements.txt',
        :owner        => 'helios',
        :group        => 'helios',
        :cwd          => '/opt/helios-web/virtualenv',
        :timeout      => 0,
      }).that_requires('Vcsrepo[/opt/helios-web/helios]')
      should contain_user('helios').with({
        :gid => 'helios',
      })
    end

    context 'with db_engine => postgres' do
      let :params do
        default_params.merge({
          :db_engine => 'postgres',
        })
      end
      it { should contain_package('postgresql-devel') }
    end

  end

end
