require 'spec_helper'

describe 'apache::config_fragment', :type => :define do

  let :title do
    'spec_test'
  end

  describe 'for OS agnostic config' do

    ['Debian', 'Redhat'].each do |osfam|
      context "on #{osfam} operating system family" do
        let :facts do
          {
            :osfamily               => osfam,
            :operatingsystemrelease => '6',
            :concat_basedir         => '/dne',
          }
        end

        it 'should fail if apache class is not included' do
          expect {
            should contain_resource_count(0)
          }.to raise_error(Puppet::Error, /You must include the apache base class/)
        end

        context 'on missing parameters' do
          let :pre_condition do
            'include apache'
          end
          it 'should fail if content and source are missing' do
            expect {
              should contain_resource_count(0)
            }.to raise_error(Puppet::Error, /must pass either 'content' or 'source'/)
          end
        end

        context 'on content and source defined' do
          let :pre_condition do
            'include apache'
          end
          let :params do
            {
              :content => 'foo',
              :source  => 'bar',
            }
          end
          it 'should fail if both content and source are defined' do
            expect {
              should contain_resource_count(0)
            }.to raise_error(Puppet::Error, /'content' and 'source' cannot be defined at the same time/)
          end
        end

      end
    end

  end

  context "on a RedHat osfamily" do
    let :pre_condition do
      'include apache'
    end
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
      }
    end

    let :params do
      {
        :content => 'DirectoryIndex index.html'
      }
    end

    it 'should contain config fragment file' do
      should contain_file('10_conf_fragment_spec_test.conf').with(
        'ensure'  => 'file',
        'path'    => '/etc/httpd/conf.d/10_conf_fragment_spec_test.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => %r{DirectoryIndex index\.html},
        'source'  => nil
      )
    end


  end

  context "on a Debian osfamily" do
    let :pre_condition do
      'include apache'
    end
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
      }
    end
    let :params do
      {
        :content => 'DirectoryIndex index.html'
      }
    end

    it 'should contain config fragment file' do
      should contain_file('10_conf_fragment_spec_test.conf').with(
        'ensure'  => 'file',
        'path'    => '/etc/apache2/conf.d/10_conf_fragment_spec_test.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => %r{DirectoryIndex index\.html},
        'source'  => nil
      )
    end

  end
end
