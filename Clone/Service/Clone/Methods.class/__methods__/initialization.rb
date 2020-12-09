#
# Description: <Method description here>
#

task = $evm.root['service_template_provision_task']
new_service = task.destination
# need to set 'admin' as owner to skip problems in error case, real user will be set in GO-libraries_rethad method-lib
user = $evm.vmdb(:User).find_by(:name => "Administrator")
new_service[:evm_owner_id] = user.id
new_service[:miq_group_id] = user.current_group.id

src_service_id = $evm.root["dialog_src_service_id"]
$evm.log(:info, "[DEBUG] Source service id: #{src_service_id}")
service = $evm.vmdb(:service).find_by(:id => src_service_id)
service.custom_set(:clone_service_id, new_service.id)

unless $evm.get_state_var(:vm_data)
  vm_data = []
  service.vms.each do |vm|	# for vm in vms
    vm_data.push(vm.id)
  end
  $evm.set_state_var(:vm_data, vm_data)
end
