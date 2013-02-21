# encoding: utf-8

module ActiveSupport::Inflector
  def titleize_with_sca(word)
    titleize_without_sca(word).gsub(/æ/, "Æ")
  end
    
  alias_method_chain :titleize, :sca
end
