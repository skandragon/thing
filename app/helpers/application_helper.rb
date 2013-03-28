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

  def markdown_html(text)
    return '' if text.blank?

    @markdown_renderer ||= Redcarpet::Render::XHTML.new(
      :filter_html => true,
      :no_images => true,
      :no_links => true,
      :no_styles => true)
    @markdown ||= Redcarpet::Markdown.new(@markdown_renderer,
                               :no_intra_emphasis => true,
                               :strikethrough => true,
                               :superscript => true)
    @markdown.render(text).html_safe
  end
end
