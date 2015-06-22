module Factory
  module_function

  def self.included(mod)
    mod.extend(Factory)
  end

  def factter(*attributes)
    if attributes.first.is_a?(Hash)
      attributes = attributes.first
      define_method(:initialize) do
        attributes.each do |attribute, value|
          instance_variable_set("@#{attribute}", value)
        end
      end
      attributes.each do |attribute, value|
        define_attribute_setter(attribute)
      end
    else
      attributes.each do |attribute|
        define_attribute_setter(attribute)
      end
    end
  end

  def define_attribute_setter(attribute)
    define_method(attribute) do |new_value|
      instance_variable_set("@#{attribute}", new_value)
      self
    end
  end
end

