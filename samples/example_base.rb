require 'threepence'

class ExampleBase < ThreePence::Application
  java_import com.ardor3d.image.TextureStoreFormat
  java_import com.ardor3d.input.GrabbedState
  java_import com.ardor3d.renderer.state.WireframeState
  java_import com.ardor3d.util.geom.Debugger

  def initialize(title)
    super()
    @title = title
  end

  def init()
    super()
    init_keybindings
    init_wireframe
    canvas.title = @title if @title
  end

  def init_wireframe
    @wireframe_state = WireframeState.new.tap { |state| state.enabled = false }
    root.render_state = @wireframe_state
  end

  def init_keybindings
    add_trigger(ESCAPE.pressed) { exit }
    add_trigger(L.pressed) do
      @light_state.enabled = !@light_state.enabled?
      dirty_render!
    end
    add_trigger(F4.pressed) { @show_depth = !@show_depth }
    add_trigger(T.pressed) do
      @wireframe_state.enabled = !@wireframe_state.enabled?
      dirty_render!
    end
    add_trigger(B.pressed) { @show_bounds = !@show_bounds }
    add_trigger(C.pressed) do
      puts "Camera: #{self.canvas.canvas_renderer.camera}"
    end
    add_trigger(N.pressed) { |s, i, t| @show_normals = !@show_normals }
#    add_trigger(F1.pressed) { @do_shot = true }
    add_trigger(MOUSE_LEFT.clicked.or(MOUSE_RIGHT.clicked)) do |source, input_state, tpf|
      puts "clicked: #{input_state.getCurrent.mouse_state.click_counts}"
    end
    add_trigger(MOUSE_LEFT.pressed) do
      puts mouse_manager.set_grabbed_supported?
      if mouse_manager.set_grabbed_supported?
	mouse_manager.grabbed = GrabbedState::GRABBED
      end
    end
    add_trigger(MOUSE_LEFT.released) do
      if mouse_manager.set_grabbed_supported?
	mouse_manager.grabbed = GrabbedState::NOT_GRABBED
      end
    end
    add_trigger(ANY_KEY) do |source, input_state, tpf|
      key = input_state.current.keyboard_state.key_event.key_char
      puts("Key character pressed: #{key} #{key.class}")
    end
  end

  def render_debug(renderer)
    Debugger.draw_bounds root, renderer, true if @show_bounds

    if @show_normals
      Debugger.draw_normals root, renderer
      Debugger.draw_tangents root, renderer
    end

    if @show_depth
      renderer.render_buckets
      Debugger.draw_buffer TextureStoreFormat::Depth16, Debugger::NORTHEAST, renderer
    end
  end
end
