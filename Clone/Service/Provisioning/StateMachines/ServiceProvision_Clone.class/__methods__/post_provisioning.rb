task = $evm.root['service_template_provision_task']
service = task.destination
service[:visible] = true
owner = $evm.vmdb(:User).find(service.evm_owner_id)
vms_names = $evm.get_state_var(:vms_names)
$evm.vmdb(:Vm).where(:name => vms_names).each do |vm|
  vm.add_to_service(service)
  vm.owner = owner
  vm.group = service.miq_group
end

snapshots_names = $evm.get_state_var(:snapshots_names)
$evm.vmdb(:Snapshot).where(:name => snapshots_names).each(&:remove)

$evm.vmdb(:Service).find($evm.root['dialog_src_service_id']).custom_set(:cloning, nil)
