source_service = $evm.vmdb(:Service).find($evm.root['dialog_src_service_id'])
ems = source_service.vms[0].ext_management_system
snapshots_names = $evm.get_state_var(:snapshots_names)
unless $evm.vmdb(:Snapshot).where(:name => snapshots_names).count == snapshots_names.count
  $evm.root['ae_result'] = 'retry'
  $evm.root['ae_retry_interval'] = 1.minute
  ems.refresh
end

