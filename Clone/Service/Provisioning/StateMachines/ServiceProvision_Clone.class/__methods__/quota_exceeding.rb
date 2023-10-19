$evm.instantiate("/Configuration/Email/Default")
$evm.instantiate("/Configuration/Location/Default")

def quota_exceeding_email(service)
  email_attributes = $evm.object("/Configuration/Email/Default").attributes
  cpv_domain = $evm.object("/Configuration/Location/Default").attributes['cpv_domain']
  to = service.evm_owner_email
  user = $evm.vmdb(:User).find_by(:email => to)
  footer = email_attributes["signature"].to_s
  from = email_attributes["from"].to_s
  miq_help = "https://help.#{cpv_domain}"
  link_help_clone = "#{miq_help}/compute/ru/Use_of_the_Services/Configuration/Clone_Service.html"
  subject = "[#{cpv_domain.upcase}] Cloning of the service"
  body = "<h3>Hello, #{user.name}!</h3>"
  body += "<p>Your request to clone the service #{service.name} can't be complited because the quota has been exceeded.</p>"
  body += "<br><br><a href='#{link_help_clone}'>More info</a> about service cloning.<br><br>"
  body += footer
  $evm.log("info", "Sending email to <#{to}> from <#{from}> subject: <#{subject}>")
  $evm.execute('send_email', to, from, subject, body)
end
