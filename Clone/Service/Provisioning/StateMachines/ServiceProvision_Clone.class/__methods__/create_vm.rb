require 'ovirtsdk4'

def prefix(service)
  service.tenant.name.downcase
end

def create_vm(snapshot, vm, service)
  snapshot_name = snapshot.name
  vm_name = "#{prefix(service)}_" + snapshot_name
  h = {
    :name             => vm_name,
    :cluster          => {
      :name => vm.ems_cluster.name
    },
    :disk_attachments => vm.disks.map do |vm_disk|
      {
        :disk => {
          :id              => vm_disk.filename,
          :storage_domains => [{
            :id => vm.storage.ems_ref.split('/').last
          }]
        }
      }
    end,
    :snapshots        => [{
      :id => snapshot.uid_ems
    }]
  }
  vm.ext_management_system.connect.system_service.vms_service.add_from_snapshot(OvirtSDK4::Vm.new(h))
end

snapshots_names = $evm.get_state_var(:snapshots_names)
vms_names = []
snapshots_names.each do |snapshot_name|
  snapshot = $evm.vmdb(:Snapshot).find_by(:name => snapshot_name)
  vm = $evm.vmdb(:Vm).find(snapshot_name.split('-')[0])
  service = $evm.root['service_template_provision_task'].destination
  new_vm_name = "#{prefix(service)}_" + snapshot_name
  vms_names << new_vm_name
  create_vm(snapshot, vm, service)
end
$evm.set_state_var(:vms_names, vms_names)
