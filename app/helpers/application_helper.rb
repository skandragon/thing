# encoding: utf-8

module ApplicationHelper
  def application_name
    Rails.application.class.parent_name
  end

  def pretty_date_from_now(date, never = 'Never')
    if date.nil?
      return never
    end
    ret = distance_of_time_in_words_to_now(date)
    now = Time.now
    if date < now
      ret += " ago"
    elsif date > now
      ret = "in #{ret}"
    end
    ret
  end

  def as_for_protocol(protocol)
    InstructorProfileContact::PROTOCOL_TYPES[protocol]
  end

  def placeholder_for_protocol(protocol)
    type = InstructorProfileContact::PROTOCOL_TYPES[protocol]
    return "http://www.example.com/" if type == :url
    return "user@example.com" if type == :email
  end
end
