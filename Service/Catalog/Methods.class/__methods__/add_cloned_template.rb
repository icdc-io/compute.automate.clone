require 'net/http'
require 'base64'
require 'json'

require 'rbvmomi'
vm = $evm.root['service'].vms[0]
vm_name = vm.name
servername = vm.ext_management_system.ipaddress || vm.ext_management_system.hostname
rhev_username = vm.ext_management_system.authentication_userid
rhev_password = vm.ext_management_system.authentication_password

vim = RbVmomi::VIM.connect :host => servername, :user => rhev_username, :password => rhev_password, :insecure => 'true'
(dc = vim.serviceInstance.find_datacenter("Cloud2d")) || raise("datacenter not found")
vm = nil
vm = dc.vmFolder.childEntity.grep(RbVmomi::VIM::VirtualMachine).find { |x| x.name == vm_name }
unless vm
  folders = dc.vmFolder.childEntity.grep(RbVmomi::VIM::Folder)
  folders.each do |folder|
    if folder.childEntity.grep(RbVmomi::VIM::VirtualMachine).find { |x| x.name == vm_name }
      vm = folder.childEntity.grep(RbVmomi::VIM::VirtualMachine).find { |x| x.name == vm_name }
      break
    end
  end
end
svct_options = {}
disks = {}
vm.disks.each do |disk|
  disks[(disk[:key]).to_s] = disk.backing.datastore.info.name
  $evm.log('info', "disk key: #{disk[:key]}")
  $evm.log('info', "disk datastore: #{disk[:backing][:datastore][:info][:name]}")
  $evm.log('info', "disk datastore: #{disk.backing.datastore.info.name}")
end
svct_options["disk"] = disks

template_name = $evm.get_state_var(:template_name)
vm_template_name = $evm.get_state_var(:vm_template_name)
base_template = $evm.get_state_var(:base_template)
user = $evm.get_state_var(:user)
uri = URI.parse('https://localhost')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Post.new("/api/iba_service_templates", 'Content-Type' =>'application/json')

request.basic_auth 'admin', 'Capac1ty8*'
@payload = {
  "action"   => "add",
  "resource" => {
    "template"     => vm_template_name,
    "name"         => template_name,
    "user"         => user,
    "ldescription" => nil,
    "description"  => nil,
    "template_id"  => base_template.to_s,
    "image"        => nil,
    "catalog"      => "Мой каталог",
    "options"      => svct_options
  }
}.to_json

request.body = @payload
$evm.log('info', "[DBG] time before request")
http.request(request)
$evm.log('info', "[DBG] time after request")
service_template = $evm.vmdb(:service_template).find_by(:name => template_name)
$evm.log('info', "[DBG] service template #{service_template.inspect}") if service_template
(0..10).each do |_i|
  break if service_template
  sleep 10
  $evm.log('info', "[DBG] no service template")
end
$evm.log('info', "[DBG] service template #{service_template.inspect}")
