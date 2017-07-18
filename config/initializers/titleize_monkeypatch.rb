# encoding: utf-8

module TitleizeWithSCA
  def titleize(word)
    return 'THL' if word == 'thl'
    super(word).gsub(/æ/, 'Æ')
  end
end

ActiveSupport::Inflector.send(:prepend, TitleizeWithSCA)
