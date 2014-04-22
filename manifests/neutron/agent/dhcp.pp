class kickstack::neutron::agent::dhcp inherits kickstack {

  include kickstack::neutron::config

  class { "::neutron::agents::dhcp":
    debug            => $::kickstack::debug,
    interface_driver => $::kickstack::neutron_plugin ? {
                          'ovs' => 'neutron.agent.linux.interface.OVSInterfaceDriver',
                          'linuxbridge' => 'neutron.agent.linux.interface.BridgeInterfaceDriver',
                          'ml2' => 'neutron.agent.linux.interface.OVSInterfaceDriver'
                        },
    use_namespaces   => $::kickstack::neutron_network_type ? {
                          'per-tenant-router' => true,
                          default => false
                        },
    package_ensure => $::kickstack::package_version,
  }
} 
