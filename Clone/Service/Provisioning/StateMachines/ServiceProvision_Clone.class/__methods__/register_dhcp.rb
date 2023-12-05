def retry_method(network_manager)
  $evm.root['ae_result'] = 'retry'
  $evm.root['ae_retry_interval'] = 1.minute
  network_manager.refresh
end

vms_names = $evm.get_state_var(:vms_names)
vms = $evm.vmdb(:Vm).where(:name => vms_names)
network_manager = vms[0].ext_management_system.try(:network_manager)

vms.each do |vm|
  $evm.log(:info, "[ahrechushkin] registering dhcp vm #{vm.inspect}")
  nics = vm.hardware.nics
  if network_manager && nics.none?{ |nic| nic.lan&.name }
    retry_method(network_manager)
  else
    nics.each do |nic|
      cloud_network = $evm.vmdb(:CloudNetwork).find_by(:name => nic.lan&.name)
      next unless cloud_network
      port = cloud_network.network_ports.detect{ |np| np.device&.id == nic.id }
      retry_method(network_manager) unless port
    end
  end
end
