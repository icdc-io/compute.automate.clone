#
# Description: <Method description here>
#
require 'ovirtsdk4'

task = $evm.root['service_template_provision_task']
service = task.destination
service.name = task.dialog_options['dialog_service_name']
begin
  vm_data = $evm.get_state_var(:vm_data)
  vm_data.each do |vm_id|
    vm = $evm.vmdb(:Vm).find(vm_id)
    new_snapshot_name = "clone-#{vm.id}-#{Time.now.strftime('%m%d-%H%M%S')}" # rubocop:disable Rails/TimeZone"
    vm.custom_set(:service_name, service.name)
    vm.create_snapshot(new_snapshot_name, new_snapshot_name, false)
  end
rescue StandardError => error
  $evm.log(:error, "Failure to create snapshot [#{error.message}]")
end
