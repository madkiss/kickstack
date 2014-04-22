class kickstack::neutron::plugin inherits kickstack {

  include kickstack::neutron::config

  $sql_conn = getvar("${fact_prefix}neutron_sql_connection")
  $ml2_type_drivers = $::kickstack::neutron_ml2_type_drivers
  $ml2_mechanism_drivers = $::kickstack::neutron_ml2_mechanism_drivers
  $ml2_flat_networks = $::kickstack::neutron_ml2_flat_networks
  $ml2_vxlan_group = $::kickstack::neutron_ml2_vxlan_group
  $ml2_vni_ranges = $::kickstack::neutron_ml2_vni_ranges
  $ml2_enable_security_group = $::kickstack::neutron_ml2_enable_security_group
  $ml2_firewall_driver = $::kickstack::neutron_ml2_firewall_driver
  $tenant_network_type = $::kickstack::neutron_tenant_network_type

  case "$::kickstack::neutron_plugin" {
    'ml2': {
      if 'gre' in $tenant_network_type {
        $network_vlan_ranges = ['']
      } else {
        $network_vlan_ranges = ["${::kickstack::neutron_physnet}:${::kickstack::neutron_network_vlan_ranges}"]
      }
    }
    default: {
      $network_vlan_ranges = $tenant_network_type ? {
      'gre' => '',
      default => "${::kickstack::neutron_physnet}:${::kickstack::neutron_network_vlan_ranges}",
      }
    }
  }

  case "$::kickstack::neutron_plugin" {
    'ml2': {
      if 'gre' in $tenant_network_type {
        $tunnel_id_ranges = ["${::kickstack::neutron_tunnel_id_ranges}"]
      } else {
        $tunnel_id_ranges = ['']
      }
    }
    default: {
      $tunnel_id_ranges = $tenant_network_type ? {
        'gre' => $::kickstack::neutron_tunnel_id_ranges,
        default => '',
      }
    }
  }

  case "$::kickstack::neutron_plugin" {
    'ovs': {
      class { "neutron::plugins::ovs":
        sql_connection => $sql_conn,
        tenant_network_type => $tenant_network_type,
        network_vlan_ranges => $network_vlan_ranges,
        tunnel_id_ranges => $tunnel_id_ranges,
        package_ensure => $::kickstack::package_version,
      }
    }
    'linuxbridge': {
      class { "neutron::plugins::linuxbridge":
        sql_connection => $sql_conn,
        tenant_network_type => $tenant_network_type,
        network_vlan_ranges => $network_vlan_ranges,
        package_ensure => $::kickstack::package_version,
      }
    }
    'ml2': {
      class { "neutron::plugins::ml2":
        type_drivers => $ml2_type_drivers,
        tenant_network_types => $tenant_network_type,
        mechanism_drivers => $ml2_mechanism_drivers,
        flat_networks => $ml2_flat_networks,
        network_vlan_ranges => $network_vlan_ranges,
        tunnel_id_ranges => $tunnel_id_ranges,
        vxlan_group => $ml2_vxlan_group,
        vni_ranges => $ml2_vni_ranges,
        enable_security_group => $ml2_enable_security_group,
        firewall_driver => $ml2_firewall_driver,
      }
    }
  } 
}
