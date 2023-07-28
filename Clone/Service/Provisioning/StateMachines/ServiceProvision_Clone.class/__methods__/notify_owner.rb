$evm.instantiate("/Configuration/Email/ServiceActions")

def send_email(service, ips)
  attributes = $evm.object("/Configuration/Email/ServiceActions").attributes
  user = service.evm_owner
  to = user.email
  footer = attributes["footer"]
  from = $evm.root['from']
  miq_help = attributes["miq_help"]
  new_service_name = service.name
  new_service_id = service.id
  source_service = $evm.vmdb(:Service).find($evm.root['dialog_src_service_id'])
  link_help_conn = "#{miq_help}/compute/ru/Use_of_the_Services/VM/Service_Access.html"
  link_help_clone = "#{miq_help}/compute/ru/Use_of_the_Services/Configuration/Clone_Service.html"
  link_service = "https://compute.#{location(service)}.#{ENV['CPV_NAME'].downcase}.io/ui/service/services/#{new_service_id}"
  subject = "[#{ENV['CPV_NAME']}.IO] Cloning of the service - #{source_service.name}"
  body = "<h3>Hello, #{user.name}!</h3>"
  body += "Your request to clone the service has been completed."
  body += "<br/><br/>The service was created with the following characteristics:"
  body += "<table  border='1'>
           <tr>
               <td>New service name</td>
               <td>#{new_service_name}</td>
           </tr>"
  service.vms.each do |new_vm|
    body += "<tr>
          <td>New vm name </td>
          <td>#{new_vm.name}</td>
          </tr>"
  end 
  body += "<tr>
    	<td>IP(s) </td>
        <td>#{ips}</td>
        </tr>"
  body += "<tr>
             <td>Service URL</td>
             <td><a href='#{link_service}'>#{link_service}</a></td>
         </tr>
         <tr>
             <td>Other access type.</td>
             <td><a href='#{link_help_conn}'>More info</a></td>
         </tr>
       </table>"
  body += "<br><br><a href='#{link_help_clone}'>More info</a> about service cloning.<br><br>"
  body += footer.to_s
  $evm.log("info", "Sending email to <#{to}> from <#{from}> subject: <#{subject}> body: #{body}")
  $evm.execute('send_email', to, from, subject, body)
end

def location(service)
  service.region_description.downcase
end

task = $evm.root['service_template_provision_task']
service = task.destination
ips = service.vms.collect(&:ipaddresses).flatten

unless ips.empty?
  send_email(service, ips.join(','))
else
  network_manager = service.vms[0].ext_management_system.try(:network_manager)
  $evm.root['ae_result'] = 'retry'
  $evm.root['ae_retry_interval'] = 3.minute
  service.vms[0].ext_management_system.refresh
  network_manager.refresh
end
