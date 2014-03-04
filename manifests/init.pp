# Class: odaiWeb
#
# This module manages odaiWeb
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class odaiweb ($repos) {
  $appjboss = hiera('appjboss', undef)
  $teiidjboss = hiera('teiidjboss', undef)

  class { 'apache':
    default_mods  => false,
    default_vhost => false
  }

  class { 'odaiweb::default_mods':
  }

  class { 'apache::mod::php':
  }

  anchor { 'odaiweb::apache_installed': }

  $mod_cluster_tarball_name = 'mod_cluster-1.2.0.Final-linux2-x64-so.tar.gz'
  $mod_cluster_tarball_url = "http://${repos}/${mod_cluster_tarball_name}"

  # install the mod_cluster stuff
  exec { "get-mod-cluster":
    cwd     => '/tmp',
    command => "/usr/bin/wget ${mod_cluster_tarball_url}",
    creates => "/tmp/${mod_cluster_tarball_name}",
    require => [Anchor['odaiweb::apache_installed']]
  }

  exec { "extract-mod-cluster":
    cwd     => '/tmp',
    command => "/bin/tar -xvzf /tmp/${mod_cluster_tarball_name} -C /etc/httpd/modules",
    creates => "/etc/httpd/modules/mod_manager.so",
    require => Exec['get-mod-cluster']
  }

  apache::mod { 'slotmem':
    lib     => 'mod_slotmem.so',
    require => Exec['extract-mod-cluster']
  }

  apache::mod { 'manager':
    lib     => 'mod_manager.so',
    require => Exec['extract-mod-cluster']
  }

  apache::mod { 'proxy_cluster':
    lib     => 'mod_proxy_cluster.so',
    require => Exec['extract-mod-cluster']
  }

  apache::mod { 'advertise':
    lib     => 'mod_advertise.so',
    require => Exec['extract-mod-cluster']
  }

  $allows = "${::network_eth0}/24"

  #  $mod_cluster_app_name=
  apache::vhost { "${::ipaddress}:${teiidjboss['mod_cluster_port']}":
    ip              => $::ipaddress,
    port            => $teiidjboss['mod_cluster_port'],
    docroot         => '/var/www/html',
    directories     => [
      {
        'path'       => '/',
        'provider' => 'location',
        'allow'    => "from all",
#        'deny'     => 'from all',
        'order'    => [
          'allow',
          'deny'],
      }
      ,
      {
        'path'       => '/mod_cluster-manager',
        'provider' => 'location',
        'allow'    => "from all",
#        'deny'     => 'from all',
        'order'    => [
          'allow',
          'deny'],
        'custom_fragment'=>'SetHandler mod_cluster-manager',
      }
      ],
    custom_fragment => "  KeepAliveTimeout 60\n  MaxKeepAliveRequests 0\n  ManagerBalancerName ${teiidjboss['balancer']}\n  AdvertiseFrequency 5\n  EnableMCPMReceive\n  ServerAdvertise On",
  }

  /*
   * apache::vhost::mod_cluster { "${::ipaddress}_${teiidjboss['mod_cluster_port']}":
   * ip                    => $::ipaddress,
   * port                  => $teiidjboss['mod_cluster_port'],
   * allow_from            => $allows,
   * manager_balancer_name => $teiidjboss["balancer"],
   *}
   */
  @@jbossas::set_mod_cluster { "cluster_app":
    proxy_name => $::fqdn,
    port       => $appjboss['mod_cluster_port'],
    balancer   => $appjboss["balancer"],
    tag        => $appjboss["mod_cluster_tag"]
  }

  @@jbossas::set_mod_cluster { "cluster_vdb":
    proxy_name => $::fqdn,
    port       => $teiidjboss['mod_cluster_port'],
    balancer   => $teiidjboss["balancer"],
    tag        => $teiidjboss["mod_cluster_tag"]
  }

  # per avere il bilanciatore che viene visto
  # /profile=ha/subsystem=modcluster/mod-cluster-config=configuration:write-attribute(name=proxy-list,value=apache.prod.italy.cloudlabcsi.eu:10001)
  # il nome su cluster e jboss devono essere uguali
  # /profile=ha/subsystem=modcluster/mod-cluster-config=configuration:write-attribute(name=balancer,value=mycluster)

  # Configure Zabbix for Apache
  # we need to set up the apache module
  #  $var = 'UserParameter=apache.status[*],curl -s http://127.0.0.1/server-status?auto| awk \'/$1: / {print $NF}\''
  exec { 'zabbix-agentd-apache':
    command => '/bin/echo "UserParameter=apache.status[*],curl -s http://127.0.0.1/server-status?auto| awk \'/\$1: / {print \$NF}\'" >> /etc/zabbix/zabbix_agentd.conf',
    require => File['/etc/zabbix/zabbix_agentd.conf'],
    unless  => '/bin/grep -q apache.status /etc/zabbix/zabbix_agentd.conf',
  }

  exec { 'zabbix-agent-apache':
    command => '/bin/echo "UserParameter=apache.status[*],curl -s http://127.0.0.1/server-status?auto| awk \'/\$1: / {print \$NF}\'" >> /etc/zabbix/zabbix_agent.conf',
    require => File['/etc/zabbix/zabbix_agent.conf'],
    unless  => '/bin/grep -q apache /etc/zabbix/zabbix_agent.conf',
  }

  $nodejs_tarball_name = 'node-v0.9.9-linux-x64.tar.gz'
  $nodejs_tarball_url = "http://nodejs.org/dist/v0.9.9/${nodejs_tarball_name}"

  exec { "get-nodejs":
    cwd     => '/tmp',
    command => "/usr/bin/wget ${nodejs_tarball_url}",
    creates => "/tmp/${nodejs_tarball_name}",
  }

  exec { "extract-nodejs":
    cwd     => '/usr/local',
    command => "/bin/tar -xvzf /tmp/${nodejs_tarball_name} --strip=1",
    creates => "/usr/local/bin/node",
    require => Exec['get-nodejs']
  }
  

}
