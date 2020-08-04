args = ['1.1']
vm = $evm.root['vm']
user = $evm.root['user']
args << {'name'         => vm.name,
         'request_type' => 'clone_to_template'}
# second_part_mac="1E:3E:07"
second_part_mac = (1..3).map { "%0.2X" % rand(256) }.join(":")
first_part_mac = "00:50:56:"
args << {'vm_name'     => vm.name + "_template",
         'mac_address' => first_part_mac + second_part_mac}
email = if user.email.nil?
          "example@gmail.com"
        else
          user.email
        end
first_name = if user.first_name.nil?
               "first_name"
             else
               user.first_name
             end
last_name = if user.last_name.nil?
              "last_name"
            else
              user.last_name
            end
args << {'owner_email'      => email,
         'owner_first_name' => first_name,
         'owner_last_name'  => last_name}
args << nil
request = $evm.execute('create_provision_request', *args)
$evm.log("info", "user - #{user.name}")
$evm.log("info", "request.options - #{request.options}")
