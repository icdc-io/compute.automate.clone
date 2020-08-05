args = ['1.1']

service = $evm.root['service']
$evm.set_state_var(:base_template, service.service_template_id)
vm = service.vms[0]
template_name = $evm.root['dialog_template_name']
vm_template_name = "#{vm.name}-#{Time.zone.now.strftime("%Y%m%d-%H%M")}_template"
user = $evm.root['user']
$evm.set_state_var(:user, user.id)

args.push(
  'name'         => vm.name,
  'request_type' => 'clone_to_template'
)

second_part_mac = (1..3).map { "%0.2X" % rand(256) }.join(":")
first_part_mac = "00:50:56:"
# storage = $evm.vmdb('Storage').find_by(:name => 'slow_storage')
args.push(
  'vm_name'     => vm_template_name,
  'mac_address' => first_part_mac + second_part_mac,
)
email = user.email || "example@gmail.com"
first_name = user.first_name || "first_name"
last_name = user.last_name || "last_name"

args.push(
  'owner_email'      => email,
  'owner_first_name' => first_name,
  'owner_last_name'  => last_name
)

args.push(nil)

request = $evm.execute('create_provision_request', *args)

$evm.log("info", "[DBG] request options - #{request.options}")
$evm.set_state_var(:template_name, template_name)
$evm.set_state_var(:vm_template_name, vm_template_name)
