# encoding: utf-8

module InstructorProfileHelper
  # Return the protocol for use in simple_form's :as parameter
  def as_for_protocol(protocol)
    InstructorProfileContact::PROTOCOL_TYPES[protocol]
  end

  # Return the placeholder text for user in simple_form's :placeholder
  # parameter
  def placeholder_for_protocol(protocol)
    type = InstructorProfileContact::PROTOCOL_TYPES[protocol]
    return "http://www.example.com/" if type == :url
    return "user@example.com" if type == :email
  end
end
