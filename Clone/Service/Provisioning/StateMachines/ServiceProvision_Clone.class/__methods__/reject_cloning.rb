$evm.instantiate("/ICDC/Service/Email/Email/Email")

def reject_cloning_email(service)
  attributes = $evm.object("/ICDC/Service/Email/Email/Email").attributes
  to = service.evm_owner_email
  user = $evm.vmdb(:User).find_by(:email => to)
  footer = attributes["footer"].to_s
  from = attributes["from"].to_s
  miq_help = attributes["miq_help"].to_s
  link_help_clone = "#{miq_help}/compute/ru/Use_of_the_Services/Configuration/Clone_Service.html"
  subject = "[ICDC.IO] Cloning of the service"
  body = "<h3>Hello, #{user.name}!</h3>"
  body += "<p>Your request to clone the service #{service.name} can't be complited while other cloning is running.</p>"
  body += "<br><br><a href='#{link_help_clone}'>More info</a> about service cloning.<br><br>"
  body += footer
  $evm.log("info", "Sending email to <#{to}> from <#{from}> subject: <#{subject}>")
  $evm.execute('send_email', to, from, subject, body)
end
