def send_email(parent_vm, new_vm)
  user = $evm.vmdb(:User).find_by(:id => parent_vm.evm_owner_id)
  to = user.email
  footer = $evm.root['footer']
  from = $evm.root['from']
  miq_help = $evm.root['miq_help']
  new_service_name = new_vm.service.name
  new_service_id = new_vm.service.id
  link_help_conn = "#{miq_help}/compute/ru/Use_of_the_Services/Service_Access.html"
  link_help_clone = "#{miq_help}/compute/ru/Use_of_the_Services/Clone_Service.html"
  link_service = "#{$evm.root['miq_service_url']}/services/#{new_service_id}"
  ip = wait_ip(new_vm)
  subject = "[ICDC.IO] Cloning of the service - #{parent_vm.service.name}"
  body = "<h3>Hello, #{user.name}!</h3>"
  body += "Your request to clone the service has been completed."
  body += "<br/><br/>The service was created with the following characteristics:"
  body += "<table  border='1'>
           <tr>
               <td>New service name</td>
               <td>#{new_service_name}</td>
           </tr>"
  body += "<tr>
    	<td>New vm name </td>
        <td>#{new_vm.name}</td>
        </tr>"
  body += "<tr>
    	<td>Parent vm name </td>
        <td>#{parent_vm.name}</td>
        </tr>"
  body += "<tr>
    	<td>IP </td>
        <td>#{ip}</td>
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
