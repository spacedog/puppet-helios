require 'spec_helper'
describe 'helios' do
  let(:facts) {
    {
      :fqdn            => 'test.example.com',
      :hostname        => 'test',
      :ipaddress       => '192.168.0.1',
      :operatingsystem => 'CentOS',
      :osfamily        => 'RedHat'
    }
  }

  context 'with defaults for all parameters' do
    it { should contain_class('helios') }
    it { should contain_anchor('helios::begin') }
    it { should contain_class('helios::install').that_requires('Anchor[helios::begin]') }
    it { should contain_class('uwsgi').that_subscribes_to('Class[helios::install]') }
    it { should contain_anchor('helios::end') }
  end
end
