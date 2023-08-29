#
# Description: This method used for removing system's default group from interface and then assign assign account's private security group
#

module Clone
  module Automation
    module Service
      module Provisioning
        module StateMachines
          class SecurityGroup
            def initialize(handle = $evm)
              @handle = handle
              vms_names = $evm.get_state_var(:vms_names)
              @vms = @handle.vmdb(:Vm).where(:name => vms_names)
              source_vm_ids = @vms.map { |vm| vm.name =~ /_(\d*)-/; $1 }
              @source_vms = @handle.vmdb(:Vm).where(:id => source_vm_ids)
              @network_manager = @vms[0].ext_management_system.try(:network_manager)
            end

            def update_security_groups
              @vms.each do |vm|
                vm.name =~ /_(\d*)-/
                source_vm = @source_vms.find { |s_vm| s_vm.id == $1.to_i }
                copy_security_groups(source_vm, vm)
              end
            end
            
            private
            
            def copy_security_groups(source_vm, vm)
              source_nics = source_vm&.nics
              nics = vm&.nics
              return unless source_nics && nics
              ns = vm.ext_management_system.network_manager.openstack_handle.detect_network_service
              nics.each do |nic|
                source_nic = source_nics.find { |s_nic| s_nic.lan_id == nic.lan_id }
                next unless source_nic
        
                security_groups = find_security_groups(source_nic)
                set_security_groups(nic, security_groups, ns)
              end
            end
            
            def find_security_groups(nic)
              port = @handle.vmdb(:NetworkPort).find_by(:device_id => nic.id)
              sg = port&.security_groups
            end
            
            def set_security_groups(nic, security_groups, ns)
              return unless security_groups.present?
              
              port = @handle.vmdb(:NetworkPort).find_by(:device_id => nic.id)
              return unless port
              
              ns.update_port(port.ems_ref, {:security_groups => security_groups.pluck(:ems_ref)})
            rescue RuntimeError => e
              @handle.log(:error, "[ICDC] Could not set security group NIC ID [#{nic.id}] SG [#{security_groups&.pluck(:name)}]")
              @handle.log(:error, "[ICDC] Error: #{e.message}")
            end
          end
        end
      end
    end
  end
end

begin
  Clone::Automation::Service::Provisioning::StateMachines::SecurityGroup.new.update_security_groups
rescue => e
  $evm.log(:error, "[ICDC] Error settings SecurityGroup: #{e.message}")
end
