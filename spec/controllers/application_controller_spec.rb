require 'spec_helper'

describe ApplicationController do
  it "formats auth error message" do
    resource = Struct.new("ResourceStruct", :id)
    message = controller.send(:authorization_failure_message, "FOO", "BAR", resource.new(12345))
    message.should include('Not authorized.')
    message.should include('FOO')
    message.should include('BAR')
    message.should include('ResourceStruct')
    message.should include('12345')
  end
end
