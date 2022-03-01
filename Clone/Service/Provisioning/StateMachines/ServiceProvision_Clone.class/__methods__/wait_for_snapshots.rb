begin
  source_service = $evm.vmdb(:Service).find($evm.root['dialog_src_service_id'])
  ems = source_service.vms[0].ext_management_system
  snapshots_names = $evm.get_state_var(:snapshots_names)
  unless $evm.vmdb(:Snapshot).where(:name => snapshots_names).count == snapshots_names.count
    $evm.root['ae_result'] = 'retry'
    $evm.root['ae_retry_interval'] = 1.minute
    ems.refresh
  end
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  $evm.vmdb(:Service).find($evm.root['dialog_src_service_id']).custom_set(:cloning, nil)
  $evm.root['ae_reason'] = "Unspecified error, see automation.log for backtrace"
  $evm.root['ae_result'] = 'error'
  $evm.root['service_template_provision_task'].destination.remove_from_vmdb
  exit MIQ_ABORT
end
