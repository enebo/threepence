require 'example_base'

java_import com.ardor3d.image.Texture
java_import com.ardor3d.image.util.GeneratedImageFactory
java_import com.ardor3d.math.ColorRGBA
java_import com.ardor3d.math.functions.Functions
java_import com.ardor3d.math.functions.MandelbrotFunction3D
java_import com.ardor3d.renderer.queue.RenderBucketType
java_import com.ardor3d.renderer.state.TextureState
java_import com.ardor3d.scenegraph.hint.LightCombineMode
java_import com.ardor3d.util.TextureKey


class Mandlebrot < ExampleBase
  def initialize
    super("Mandlebrot Explorer")
  end

  def init_application
    cam = canvas.canvas_renderer.camera

    root.layout do
      quad(:display) do 
        resize cam.width, cam.height
        at cam.width / 2, cam.height / 2, 0
        scene_hints.light_combine_mode = LightCombineMode::Off
        scene_hints.render_bucket_type = RenderBucketType::Ortho
      end
    end

    @display = root.find_child :display
    @tex = com.ardor3d.image.Texture2D.new
    @trans = Vector2 -0.7, 0
    @scale = Vector2 1.5, 1.5
    @iterations = 80.0
    @colors = Array.new(256).tap do |c|
      c[0] = ColorRGBA::BLUE
      c[30] = ColorRGBA::YELLOW
      c[70] = ColorRGBA::BLUE
      c[140] = ColorRGBA::WHITE
      c[220] = ColorRGBA::BROWN
      c[255] = ColorRGBA::BLACK
    end.to_java(com.ardor3d.math.type.ReadOnlyColorRGBA)
    GeneratedImageFactory.fill_in_color_table @colors
    root.set_render_state(TextureState.new.tap { |ts| ts.texture = @tex })
    update_texture
  end

  def init_keybindings
    super
    add_trigger(MOUSE_LEFT.pressed) do |source, input_state, tpf| # zoom in
      width, height = @display.width.to_f, @display.height.to_f
      half = Vector2 2.0 / width, 2.0 / height
      mouse = input_state.current.mouse_state
      add = Vector2 mouse.x.to_f - 0.5 * width, mouse.y.to_f - 0.5 * height
      add.multiply_local(@scale).multiply_local(half)
      @trans.add_local add.x, add.y
      @scale.multiply_local 0.5
      @iterations *= 1.1
      update_texture
    end
    add_trigger(MOUSE_RIGHT.pressed) do |source, input_state, tpf| # zoom out
      width, height = @display.width.to_f, @display.height.to_f
      half = Vector2 2.0 / width, 2.0 / height
      mouse = input_state.current.mouse_state
      add = Vector2 mouse.x.to_f - 0.5 * width, mouse.y.to_f - 0.5 * height
      add.multiply_local(@scale).multiply_local(half)
      @trans.add_local add.x, add.y
      @scale.multiply_local 1.0 / 0.5
      @iterations /= 1.1
      update_texture
    end
  end

  def update_texture
    # Build up our function
    mandel_base = MandelbrotFunction3D.new @iterations.round
    translated_mandel = Functions.translate_input(mandel_base, @trans.x, @trans.y, 0)
    final_mandel = Functions.scale_input(translated_mandel, @scale.x, @scale.y, 1)

    cam = canvas.canvas_renderer.camera
    img = GeneratedImageFactory.createLuminance8Image(final_mandel, cam.width, cam.height, 1)

    img = GeneratedImageFactory.createColorImageFromLuminance8(img, false, @colors)
    @tex.image = img
    @tex.texture_key = TextureKey.get_rtt_key Texture::MinificationFilter::Trilinear
    @tex.magnification_filter = Texture::MagnificationFilter::Bilinear
    @tex.minification_filter = Texture::MinificationFilter::Trilinear
  end
end

Mandlebrot.start
