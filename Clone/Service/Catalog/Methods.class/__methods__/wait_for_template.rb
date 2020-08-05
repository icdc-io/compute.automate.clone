vm_template_name = $evm.get_state_var(:vm_template_name)
template = $evm.vmdb(:vm_or_template).find_by(:name => vm_template_name)

begin
  if template
    $evm.log('info', "[DBG] Found template #{template.inspect}")
    $evm.root['ae_result'] = 'ok'
  else
    $evm.log('info', "[DBG] Not found template #{template.inspect}")
    $evm.root['ae_result'] = 'retry'
    $evm.root['ae_retry_interval'] = '30.seconds'
  end
rescue StandardError => e
  $evm.root['ae_result'] = 'error'
  $evm.log('error', e.message)
  $evm.root['ae_reason'] = 'Unexpected error while waiting for task to finish'
end
