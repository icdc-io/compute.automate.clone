def refresh
  $evm.root['ae_result'] = 'retry'
  $evm.root['ae_retry_interval'] = 3.minute
  source_service = $evm.vmdb(:Service).find($evm.root['dialog_src_service_id'])
  ems = source_service.vms.first.ext_management_system
  ems.refresh
  exit MIQ_OK
end

vms_names = $evm.get_state_var(:vms_names)
vms = $evm.vmdb(:Vm).where(:name => vms_names)

refresh unless vms.count == vms_names.count

refresh unless vms.all?{|vm| vm.power_state == "on" || (vm.start && false) }

vms.each(&:clone_miq_provision)
