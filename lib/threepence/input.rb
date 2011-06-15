require 'threepence/util/guava'

module ThreePence
  class KeyInput
    def initialize(ardor_key_value)
      @key = ardor_key_value
    end

    def held
      com.ardor3d.input.logical.KeyHeldCondition.new(@key)
    end

    def pressed
      com.ardor3d.input.logical.KeyPressedCondition.new(@key)
    end

    def released
      com.ardor3d.input.logical.KeyReleasedCondition.new(@key)
    end
  end

  class MouseInput
    def initialize(ardor_button_value)
      @button = ardor_button_value
    end

    def clicked
      com.ardor3d.input.logical.MouseButtonClickedCondition.new(@button)
    end

    def moved
      com.ardor3d.input.logical.MouseButtonMovedCondition.new(@button)
    end

    def pressed
      com.ardor3d.input.logical.MouseButtonPressedCondition.new(@button)
    end

    def released
      com.ardor3d.input.logical.MouseButtonReleasedCondition.new(@button)
    end
  end

  module Input
    com.ardor3d.input.Key.constants.each do |key|
      const_set(key, KeyInput.new(com.ardor3d.input.Key.const_get(key)))
    end

    # To avoid name conflicts with keys we prefix all these constants
    mouse_button = com.ardor3d.input.MouseButton
    mouse_button.constants.each do |name|
      const_set "MOUSE_" + name, MouseInput.new(mouse_button.const_get(name))
    end

    # Add a trigger to fire when the appropriate condition occurs.
    # This returns the trigger registered so you can save it and possibly
    # remove it later.
    def add_trigger(condition, name=nil, &action)
      trigger = com.ardor3d.input.logical.InputTrigger.new(condition, &action)
      trigger.set_id(name) if name
      logical.registerTrigger(trigger)
      trigger
    end

    ANY_KEY = com.ardor3d.input.logical.AnyKeyCondition.new
  end
end
