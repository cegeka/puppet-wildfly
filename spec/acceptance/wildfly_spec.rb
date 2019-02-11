require 'spec_helper_acceptance'

describe 'wildfly' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include yum
        include stdlib
        include stdlib::stages
        include profile::package_management

        class { 'cegekarepos' : stage => 'setup_repo' }

        Yum::Repo <| title == 'cegeka-custom' |>
        Yum::Repo <| title == 'cegeka-custom-noarch' |>
        Yum::Repo <| title == 'cegeka-unsigned' |>
        Yum::Repo <| title == 'epel' |>

        sunjdk::instance { 'jdk1.8.0_40':
          ensure      => 'present',
          pkg_name    => 'jdk1.8.0_40',
          jdk_version => '1.8.0_40-fcs',
          versionlock => true
        }

        file { '/data':
          ensure => 'directory'
        }

        file { '/data/logs':
          ensure => 'directory'
        }
        
        package { 'cronie':
          ensure => 'present'
        }
        
        class { 'wildfly':
          version                 => '8.2.0-3.cgk.el7',
          versionlock             => false,
          service_state           => 'running',
          service_enable          => true,
          java_home               => '/usr/java/jdk1.8.0_40',
          jboss_mode              => 'standalone',
          jboss_config            => 'standalone',
          jboss_bind_address      => '0.0.0.0',
          jboss_bind_address_mgmt => '0.0.0.0',
          jboss_min_mem           => '256',
          jboss_max_mem           => '512',
          jboss_perm              => '128',
          jboss_max_perm          => '192',
          jboss_debug             => false,
          jboss_user              => 'wildfly',
          jboss_group             => 'wildfly',
          jboss_data_dir          => '/opt/wildfly',
          jboss_shutdown_wait     => '60',
          jboss_log_dir           => '/data/logs/wildfly',
          newrelic_enabled        => false,
          gc_disabled             => false,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
    describe package('wildfly82') do
      it { should be_installed }
    end
  end
end
