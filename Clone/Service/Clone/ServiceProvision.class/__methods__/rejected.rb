#
# Description: <Method description here>
#
module Clone
  module Service
    module Clone
      module ServiceProvision 
        class Rejected
          def initialize(handle = $evm)
            @handle = handle
          end
    
          def main
            rejected
          end
    
          private
    
          def rejected
            request = @handle.root['miq_request']
            @handle.log('info', "Request denied because of #{request.message}")
            request.deny('admin', 'Quota Exceeded')
    
            @handle.create_notification(:level => 'error', :subject => request, :message => "Quota Exceeded: #{request.message}")
          end
        end
      end
    end
  end
end
