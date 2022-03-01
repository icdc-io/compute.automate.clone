source_service_id = $evm.root['dialog_src_service_id']
source_service = $evm.vmdb(:Service).find_by(:id => source_service_id)
$evm.log(:info, "[ahrechushkin] source_service -> #{source_service.inspect}")
task = $evm.root['service_template_provision_task']
service = task.destination

unless source_service.custom_get(:cloning)
  source_service.custom_set(:cloning, true)
  vms = source_service.vms
  snapshots_names = []
  vms.each do |vm|
    snapshot_name = "#{vm.id}-#{Time.now.strftime('%m%d-%H%M%S')}"
    snapshots_names << snapshot_name
    vm.create_snapshot(snapshot_name, snapshot_name, false)
  end
  $evm.set_state_var(:snapshots_names, snapshots_names)
else
  reject_cloning_email(service)
  service.remove_from_vmdb
  exit MIQ_ABORT
end



