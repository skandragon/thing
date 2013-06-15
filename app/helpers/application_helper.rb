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
      ret += ' ago'
    elsif date > now
      ret = "in #{ret}"
    end
    ret
  end
end
