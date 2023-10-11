module Clone
  module Automation
    module Service
      module Provisioning
        module StateMachines
          class NotifyOwner
			def initialize
			  @handle.instantiate("/Operator/Configuration/Email/Default")
			  @handle.instantiate("/Operator/Configuration/Location/Default")
              email_attributes = @handle.object("/Operator/Configuration/Email/Default").attributes
  			  @cpv_domain = @handle.object("/Operator/Configuration/Location/Default").attributes['cpv_domain']
              @footer = email_attributes["signature"].to_s
              @location = @service.region_description.downcase
            end

            def send_email
              main_links
              email_params
              @handle.log("info", "Sending email to <#{@to}> from <#{@from}> subject: <#{@subject}> body: #{@body}")
              @handle.execute('send_email', @to, @from, @subject, @body)
            end

            private
            
            def main_links
              miq_help = "https://help.#{@cpv_domain}"
              new_service_id = @service.id
			  @link_help_conn = "#{miq_help}/compute/ru/Use_of_the_Services/VM/Service_Access.html"
 			  @link_help_clone = "#{miq_help}/compute/ru/Use_of_the_Services/Configuration/Clone_Service.html"
  			  @link_service = "https://compute.#{@location}.#{ENV['CPV_NAME'].downcase}.io/ui/service/services/#{new_service_id}"
            end
            
            def email_params
              @user = @service.evm_owner
  			  @to = @user.email
  			  @from = @handle.root['from']
              source_service = @handle.vmdb(:Service).find(@handle.root['dialog_src_service_id'])
  			  @subject = "[#{ENV['CPV_NAME']}.IO] Cloning of the service - #{source_service.name}"
              @body = message_body
            end
            
            def message_body
              new_service_name = @service.name
              body = "<h3>Hello, #{@user.name}!</h3>"
              body += "Your request to clone the service has been completed."
              body += "<br/><br/>The service was created with the following characteristics:"
              body += "<table  border='1'>
                       <tr>
                           <td>New service name</td>
                           <td>#{new_service_name}</td>
                       </tr>"
              @service.vms.each do |new_vm|
                body += "<tr>
                      <td>New vm name </td>
                      <td>#{new_vm.name}</td>
                      </tr>"
              end 
              body += "<tr>
                    <td>IP(s) </td>
                    <td>#{@ips}</td>
                    </tr>"
              body += "<tr>
                         <td>Service URL</td>
                         <td><a href='#{@link_service}'>#{@link_service}</a></td>
                     </tr>
                     <tr>
                         <td>Other access type.</td>
                         <td><a href='#{@link_help_conn}'>More info</a></td>
                     </tr>
                   </table>"
              body += "<br><br><a href='#{@link_help_clone}'>More info</a> about service cloning.<br><br>"
              body += @footer.to_s
              body
            end
          end
        end
      end
    end
  end
end

@handle = $evm
task = @handle.root['service_template_provision_task']
@service = task.destination
@ips = @service.vms.collect(&:ipaddresses).flatten.join(',')

unless @ips.empty?
  Clone::Automation::Service::Provisioning::StateMachines::NotifyOwner.new.main.send_email
else
  network_manager = @service.vms[0].ext_management_system.try(:network_manager)
  @handle.root['ae_result'] = 'retry'
  @handle.root['ae_retry_interval'] = 3.minute
  @service.vms[0].ext_management_system.refresh
  network_manager.refresh
end
