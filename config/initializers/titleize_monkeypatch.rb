# encoding: utf-8

module ActiveSupport::Inflector
  def titleize_with_sca(word)
    return 'THL' if word == 'thl'
    titleize_without_sca(word).gsub(/æ/, 'Æ')
  end

  alias_method_chain :titleize, :sca
end
