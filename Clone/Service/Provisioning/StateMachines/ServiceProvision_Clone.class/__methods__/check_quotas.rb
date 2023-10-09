begin
  service = $evm.vmdb(:service).find_by(:id => $evm.root["dialog_src_service_id"])
  source = service.tenant.combined_quotas
  
  available = {
                :cpu     => source[:cpu_allocated][:available].to_i,
                :memory  => source[:mem_allocated][:available].to_s(:human_size).to_i, 
                :storage => (source[:storage_allocated][:available].to_f / 2**(10*3)).to_i
              }
  $evm.log("info", "Quota available: (:cpu=>#{available[:cpu]}, :memory=>#{available[:memory]} , storage=>#{available[:storage]})" )

  requested = {
                :cpu     => service.options[:dialog]["dialog_number_of_sockets"].to_i * service.options[:dialog]["dialog_cores_per_socket"].to_i,
                :memory  => (service.options[:dialog]["dialog_vm_memory"].to_f / 2**(10*1)).to_i, 
                :storage => service.options[:dialog]["dialog_system_disk_size"].to_i
              }
  $evm.log("info", "requested: (:cpu=>#{requested[:cpu]}, :memory=>#{requested[:memory]} , storage=>#{requested[:storage]})" )   
rescue => error
  $evm.log("info", "error in check_quotas method: #{error}")
  available = {:cpu => 0, :memory => 0, :storage => 0}
  requested = {:cpu => 0, :memory => 0, :storage => 0}
end
service = $evm.vmdb(:Service).find($evm.root["service_id"])
if source[:cpu_allocated][:unit].nil? || source[:mem_allocated][:unit].nil? || source[:storage_allocated][:unit].nil?
  $evm.log(:error, "Quotas are not set")
  $evm.create_notification(:audience => 'user', :message => "Quotas are not set!", :level => 'error')
  service.remove_from_vmdb
  $evm.root['ae_result'] = 'error'
  $evm.root['ae_reason'] = "Quotas are not set"
  exit MIQ_ABORT
elsif available[:cpu] < requested[:cpu] || available[:memory] < requested[:memory] || available[:storage] < requested[:storage]
  $evm.log(:error, "Quota exceeded")
  $evm.create_notification(:audience => 'user', :message => "Quota exceeded!", :level => 'error')
  quota_exceeding_email(service)
  service.remove_from_vmdb
  $evm.root['ae_result'] = 'error'
  $evm.root['ae_reason'] = "Quota exceeded"
  exit MIQ_ABORT
end
