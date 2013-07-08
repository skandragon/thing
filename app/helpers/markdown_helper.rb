# encoding: utf-8

module MarkdownHelper
  def markdown_html(text, options = {})
    return '' if text.blank?

    options.reverse_merge!({
      tags: %w(strong em sup del),
      tags_add: [],
      tags_remove: [],
    })

    tags = Array(options[:tags])
    tags += Array(options[:tags_add])
    tags -= Array(options[:tags_remove])
    tags = tags.map(&:to_s)

    @markdown_renderer ||= Redcarpet::Render::XHTML.new(
      :filter_html => true,
      :no_images => true,
      :no_links => true,
      :no_styles => true)
    @markdown ||= Redcarpet::Markdown.new(@markdown_renderer,
                               :no_intra_emphasis => true,
                               :strikethrough => true,
                               :superscript => true)
    @coder ||= HTMLEntities.new
    sanitize(@coder.decode(@markdown.render(text.strip)), tags: tags).strip.html_safe
  end
end
