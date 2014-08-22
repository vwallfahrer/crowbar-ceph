raise "fsid must be set in config" if node["ceph"]["config"]['fsid'].nil?

mon_nodes = get_mon_nodes
osd_nodes = get_osd_nodes
mon_addresses = get_mon_addresses

mon_init = []
mon_nodes.each do |monitor|
    mon_init << monitor.name.split('.')[0]
end

directory "/etc/ceph" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

directory "/var/run/ceph" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

directory "/var/log/ceph" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

is_rgw = node.roles.include?("ceph-radosgw")

keystone_settings = {}
if is_rgw && !(node[:ceph][:keystone_instance].nil? || node[:ceph][:keystone_instance].empty?)
  keystone_settings = KeystoneHelper.keystone_settings(node, @cookbook_name)
end

template '/etc/ceph/ceph.conf' do
  source 'ceph.conf.erb'
  variables(
    :mon_initial => mon_init,
    :mon_addresses => mon_addresses,
    :osd_nodes_count => osd_nodes.length,
    :public_network => node["ceph"]["config"]["public-network"],
    :cluster_network => node["ceph"]["config"]["cluster-network"],
    :is_rgw => is_rgw,
    :keystone_settings => keystone_settings
  )
  mode '0644'
end
