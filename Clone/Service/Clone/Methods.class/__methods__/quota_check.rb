#
# Description: <Method description here>
#

service = $evm.vmdb(:service).find_by(:id => $evm.root["dialog_src_service_id"])
source = service.tenant.combined_quotas

available = {
              :cpu                 => source[:cpu_allocated][:available].to_i,
              :memory              => source[:mem_allocated][:available].to_s(:human_size).to_i, 
              :storage             => (source[:storage_allocated][:available].to_f / 2**(10*3)).to_i
        	}
$evm.log("info", "Quota available: (:cpu=>#{available[:cpu]}, :memory=>#{available[:memory]} , storage=>#{available[:storage]}" )

requested = {
              :cpu                 => service.options[:dialog]["dialog_number_of_sockets"].to_i,
              :memory              => (service.options[:dialog]["dialog_vm_memory"].to_f / 2**(10*1)).to_i , 
              :storage             => service.options[:dialog]["dialog_system_disk_size"].to_i, 
        	}
$evm.log("info", "requested: (:cpu=>#{requested[:cpu]}, :memory=>#{requested[:memory]} , storage=>#{requested[:storage]}" )      

if available[:cpu] < requested[:cpu] || available[:memory] < requested[:memory] || available[:storage] < requested[:storage] 
  $evm.instantiate('/Service/Email/Email/Email_Quota?method_name=EmailQuota')
  $evm.vmdb(:Service).find(service[:clone_service_id]).remove_from_vmdb	
  $evm.root['ae_result'] = 'error'
  $evm.root['ae_reason'] = "Quota exceeded"
  exit MIQ_ABORT 	
end
