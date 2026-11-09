$evm.instantiate("/Configuration/Email/Default")
$evm.instantiate("/Configuration/Location/Default")

def reject_cloning_email(service)
  email_attributes = $evm.object("/Configuration/Email/Default").attributes
  cpv_domain = $evm.object("/Configuration/Location/Default").attributes['cpv_domain']
  to = service.evm_owner_email
  user = $evm.vmdb(:User).find_by(:email => to)
  footer = email_attributes["signature"].to_s
  from = email_attributes["from"].to_s
  docs_url = "https://docs.#{cpv_domain}"
  link_docs_clone = "#{docs_url}/en/compute/dedicated_ui/services/configuration/clone_service/"
  subject = "[Compute] Cloning of the service"
  body = "<h3>Hello, #{user.name}!</h3>"
  body += "<p>Your request to clone the service #{service.name} can't be completed while other cloning is running.</p>"
  body += "<br><br><a href='#{link_docs_clone}'>More info</a> about service cloning.<br><br>"
  body += footer
  $evm.log("info", "Sending email to <#{to}> from <#{from}> subject: <#{subject}>")
  $evm.execute('send_email', to, from, subject, body)
end
