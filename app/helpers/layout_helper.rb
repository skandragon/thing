# encoding: utf-8

module LayoutHelper
  def render_flashes
    ret = ""
    flash.each do |name, msg|
      css_class = "alert alert-block"
      case name
      when :notice
        css_class << " alert-success"
      when :error
        css_class << " alert-error"
      when :alert
        css_class << " alert-error"
      end
      ret << '<div class="' + css_class + '">'
      ret << '<a class="close" data-dismiss="alert">×</a>'
      ret << h(msg)
      ret << "</div>"
    end
    ret.html_safe
  end

  def title(window_title)
    if window_title.is_a?Array
      new_title = ([ application_name ] + window_title)
    else
      new_title = [ application_name, window_title ]
    end
    content_for(:window_title) { new_title.join(" : ") }
  end

  def title_content
    content_for?(:window_title) ? content_for(:window_title) : application_name
  end

  def meta(args)
    args.each do |name, content|
      content_for(:meta_block) { tag(:meta, :name => name, :content => content) }
    end
  end

  def favicon_links
    ret = [
      '<link rel="shortcut icon" href="' + image_path('logo-16x16.ico') + '" />',
      '<link rel="icon" type="image/vnd.microsoft.icon" href="' + image_path('logo-16x16.ico') + '" />',
      '<link rel="icon" type="image/png" href="' + image_path('logo-16x16.png') + '" />',
      '<link rel="apple-touch-icon" href="' + image_path('logo-57x57.png') + '">',
      '<link rel="apple-touch-icon" sizes="72x72" href="' + image_path('logo-72x72.png') + '">',
      '<link rel="apple-touch-icon" sizes="114x114" href="' + image_path('logo-114x114.png') + '">',
      '<link rel="apple-touch-icon" sizes="144x144" href="' + image_path('logo-144x144.png') + '">',
    ].join("\n").html_safe
  end

  def back_button(label = 'Back', target = :back)
    link_to label, target, :class => 'btn'
  end

  def button_link_to(text, href, options = {})
    classes = (options[:class] || '').split(" ")
    classes << 'btn' unless classes.include?("btn")
    options[:class] = classes
    link_to text, href, options
  end

  def page_navigation_links(pages)
    will_paginate(pages, :class => 'pagination', :inner_window => 2, :outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label => '&larr;'.html_safe, :next_label => '&rarr;'.html_safe)
  end

  def icon(type, inverse = false)
    css_class = "icon-#{type}"
    css_class += " icon-white" if inverse
    content_tag :i, '', class: css_class
  end

  def revision
    if current_user and current_user.admin?
      begin
        content_tag :span, read_revision, :class => "revision"
      rescue
      end
    else
      nil
    end
  end

  private

  def read_revision
    @revision ||= File.read(File.join(Rails.root, "hash.txt"))
  end
end
