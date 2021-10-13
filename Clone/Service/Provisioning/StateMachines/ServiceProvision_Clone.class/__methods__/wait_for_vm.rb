source_service = $evm.vmdb(:Service).find($evm.root['dialog_src_service_id'])
ems = source_service.vms[0].ext_management_system

vms_names = $evm.get_state_var(:vms_names)
vms = $evm.vmdb(:Vm).where(:name => vms_names)
unless vms.count == vms_names.count
  $evm.root['ae_result'] = 'retry'
  $evm.root['ae_retry_interval'] = 3.minute
  ems.refresh
else
  unless vms.collect(&:power_state).uniq == ["on"]
    vms.each(&:start)
    $evm.root['ae_result'] = 'retry'
    $evm.root['ae_retry_interval'] = 3.minute
    ems.refresh
  end
end
