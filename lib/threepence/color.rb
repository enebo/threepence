module ThreePence
  module Color
    MS = com.ardor3d.renderer.state.MaterialState
    MATERIAL_TYPES = {
      'none' => MS::ColorMaterial::None,
      'ambient' => MS::ColorMaterial::Ambient,
      'diffuse' => MS::ColorMaterial::Diffuse,
      'ambient_and_diffuse' => MS::ColorMaterial::AmbientAndDiffuse,
      'specular' => MS::ColorMaterial::Specular,
      'emissive' => MS::ColorMaterial::Emissive,
    }

    # Sets up a material state for the color characteristics you want.
    # This will return the material state created in case you want to 
    # change values on it later versus replacing it.
    def color(type, o={})
      type = type.to_s
      material = MATERIAL_TYPES[type]
      raise ArgumentError.new "Invalid color/material type: #{type}" if !material

      MS.new.tap do |ms|
        ms.set_color_material material if material
        ms.set_diffuse color_for("diffuse", o[:diffuse]) if o[:diffuse]
        ms.set_ambient color_for("ambient", o[:ambient]) if o[:ambient]
        ms.set_specular color_for("specular", o[:specular]) if o[:specular]
        ms.set_emissive color_for("emissive", o[:emissive]) if o[:emissive]
        set_render_state ms
      end
    end

    COLORS = {
      'black' => com.ardor3d.math.ColorRGBA::BLACK,
      'white' => com.ardor3d.math.ColorRGBA::WHITE,
      'dark_gray' => com.ardor3d.math.ColorRGBA::DARK_GRAY,
      'gray' => com.ardor3d.math.ColorRGBA::GRAY,
      'light_gray' => com.ardor3d.math.ColorRGBA::LIGHT_GRAY,
      'red' => com.ardor3d.math.ColorRGBA::RED,
      'green' => com.ardor3d.math.ColorRGBA::GREEN,
      'blue' => com.ardor3d.math.ColorRGBA::BLUE,
      'yellow' => com.ardor3d.math.ColorRGBA::YELLOW,
      'magenta' => com.ardor3d.math.ColorRGBA::MAGENTA,
      'cyan' => com.ardor3d.math.ColorRGBA::CYAN,
      'orange' => com.ardor3d.math.ColorRGBA::ORANGE,
      'brown' => com.ardor3d.math.ColorRGBA::BROWN,
      'pink' => com.ardor3d.math.ColorRGBA::PINK,
    }

    def color_for(type, value)
      case value
      when Symbol, String then
        return COLORS[value.to_s]
      when Array then
        return com.ardor3d.math.ColorRGBA.new *value
      end

      raise ArgumentError.new "Unknown #{type} color: #{value}"
    end
    private :color_for
  end
end
