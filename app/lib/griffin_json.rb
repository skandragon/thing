module GriffinJSON
  module ClassMethods
    def json_for(target, options = {})
      options[:scope] ||= self
      options[:url_options] ||= url_options if respond_to?(:url_options)
      target.active_model_serializer.new(target, options).to_json
    end
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
end
