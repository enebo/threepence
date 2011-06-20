module ThreePence
  module ClassMethods
    # The DSLs used in ThreePence make use of instance_eval'd blocks.
    # This makes the nicer name= setters unusable.  This method allows
    # the getter name of the underlying Java method to also be the setter
    # if a value is provided.  Additionally it specifies the name of a method
    # to be called on the value that is supplied in the setter case.
    #
    # gesetter :layout_data, :layout_data_value_converter
    # gesetter :gap
    #
    def gesetter(name, transformer=nil)
      transform = transformer.nil? ? "value" : "#{transformer.to_s}(value)"
      class_eval <<-EOS
def #{name.to_s}(value=nil)
  if value.nil?
    get_#{name}
  else
    set_#{name}(#{transform})
  end
end
EOS
    end
  end
end
