require 'threepence/util/math'
require 'threepence/logger'
require 'threepence/input'
require 'threepence/texture'
require 'threepence/collisions'
require 'threepence/behaviors'
require 'threepence/ardor3d/scenegraph'
require 'threepence/ardor3d/extension/ui'
require 'threepence/lwjgl'

module ThreePence
  java_import java.lang.Runnable
  java_import com.ardor3d.framework.DisplaySettings
  java_import com.ardor3d.framework.FrameHandler
  java_import com.ardor3d.framework.Scene
  java_import com.ardor3d.framework.Updater
  java_import com.ardor3d.image.util.AWTImageLoader
  java_import com.ardor3d.input.control.FirstPersonControl
  java_import com.ardor3d.input.logical.LogicalLayer
  java_import com.ardor3d.intersection.PickingUtil
  java_import com.ardor3d.intersection.PrimitivePickResults
  java_import com.ardor3d.light.PointLight
  java_import com.ardor3d.math.ColorRGBA
  java_import com.ardor3d.math.Vector3
  java_import com.ardor3d.renderer.queue.RenderBucketType
  java_import com.ardor3d.renderer.state.LightState
  java_import com.ardor3d.renderer.state.ZBufferState
  java_import com.ardor3d.scenegraph.event.DirtyType
  java_import com.ardor3d.scenegraph.Node
  java_import com.ardor3d.util.Constants
  java_import com.ardor3d.util.ContextGarbageCollector
  java_import com.ardor3d.util.GameTaskQueue
  java_import com.ardor3d.util.GameTaskQueueManager
  java_import com.ardor3d.util.Timer
  java_import com.ardor3d.util.resource.ResourceLocatorTool
  java_import com.ardor3d.util.resource.SimpleResourceLocator

  class Application
    include Runnable, Updater, Scene, Input, Texture, Logger, CollisionExecutor

    attr_reader :logical, :physical, :world_up, :root, :canvas, :mouse_manager

    def self.start(application_class=self)
      # FIXME: Make preference loader.
      settings = DisplaySettings.new 640, 480, 24, 60, 0, 0, 0, 0, false, false
      app = application_class.new
      app.hookup_backend *LWJGL.setup(app, settings)
      java.lang.Thread.new(app).start
    end

    def initialize()
      @logical = LogicalLayer.new
      @world_up = Vector3.new 0, 1, 0
      @root = Node.new
      @timer = Timer.new
      @frame_handler = FrameHandler.new(@timer)
      @exit = false
    end

    def hookup_backend(canvas, physical, mouse_manager)
      @canvas, @physical, @mouse_manager = canvas, physical, mouse_manager
      logical.registerInput @canvas, @physical
      @controls = FirstPersonControl.setupTriggers(@logical, @world_up, true)
      @frame_handler.tap do |handler|
	handler.add_updater self
	handler.add_canvas canvas
      end
    end

    def doPick(pick_ray) # Scene
      PrimitivePickResults.new.tap do |results|
	results.check_distance = true
	PickingUtil.findPick root, pick_ray, results
	process_picks results
      end
    end

    def exit?
      @exit
    end

    def exit
      @exit = true
    end

    # Override if you want to
    def process_picks(pick_results)
    end

    def init # Updater
      AWTImageLoader.registerLoader

      init_resource_loaders
      init_zbuffer
      init_lighting

      root.scene_hints.render_bucket_type = RenderBucketType::Opaque

      canvas.title = @title if @title

      init_application

      root.update_geometric_state(0)
    end

    # This should be overriden by consumer
    def init_application
      puts "Override init_application"
    end

    def init_lighting
      @light_state = LightState.new.tap do |l|
	l.enabled = true
	l.attach(PointLight.new.tap do |pl|
		   pl.diffuse = ColorRGBA.new(0.75, 0.75, 0.75, 0.75)
		   pl.ambient = ColorRGBA.new(0.5, 0.5, 0.5, 1.0)
		   pl.location = Vector3.new(100, 100, 100)
		   pl.enabled = true
		 end)
      end
      root.render_state = @light_state
    end

    def init_resource_loaders
      base = 'file:' + ThreePence::LIB_LOCATION
      media_location = java.net.URL.new base
      model_location = java.net.URL.new base + "/models"

      locator = SimpleResourceLocator.new(media_location)
      ResourceLocatorTool.add_resource_locator(ResourceLocatorTool::TYPE_TEXTURE, locator)
      locator = SimpleResourceLocator.new(model_location)
      ResourceLocatorTool.add_resource_locator(ResourceLocatorTool::TYPE_MODEL, locator)
    rescue
       severe "in init_resource_loaders", $!
    end

    # ZBuffer to display pixels closest to the camera.
    def init_zbuffer
      root.render_state = ZBufferState.new.tap do |buffer|
	buffer.enabled = true
        buffer.writable = true
	buffer.function = ZBufferState::TestFunction::LessThanOrEqualTo
      end
    end

    def execute_queue_manager(queue)
      manager = GameTaskQueueManager.get_manager canvas_renderer.render_context
      manager.get_queue(queue).execute
    end

    def canvas_renderer
      canvas.canvas_renderer
    end

    def renderUnto(renderer) # Scene
      execute_queue_manager GameTaskQueue::RENDER

      ContextGarbageCollector.do_runtime_cleanup renderer

      closing = canvas.closing?
      unless closing
	render_application renderer
	render_debug renderer
      end
      !closing
    end

    def render_application(renderer)
      root.on_draw renderer
      renderer.render_buckets
      renderer.draw(@hud) if @hud
    end

    def render_debug(renderer)
    end

    def run # Runnable
      @frame_handler.init

      while !exit? do
	@frame_handler.update_frame
	java.lang.Thread.yield
      end
      
      canvas_renderer.tap do |cr|  # Cleanup
	cr.make_current_context
	quit cr.renderer
	cr.release_current_context
      end
      java.lang.System.exit 0 if $quit_vm_on_exit
    rescue
       severe "in run", $!
    end

    def quit(renderer)
      ContextGarbageCollector.do_final_cleanup renderer
      canvas.close
    rescue
       severe "in quit", $!
    end

    def update(timer) # Updater
      exit if canvas.closing?

      # update stats, if enabled.
      StatCollector.update if Constants.stats

      dispatch_collisions

      update_logical(timer)
      execute_queue_manager(GameTaskQueue::UPDATE)
      update_application timer

      root.update_geometric_state timer.time_per_frame, true
      @hud.update_geometric_state timer.time_per_frame, true if @hud
    rescue
      severe "in update", $!
    end

    def update_logical(timer)
      if @hud
	@hud.logical_layer.check_triggers timer.time_per_frame
      else
	logical.check_triggers timer.time_per_frame
      end
    end

    # Override for your application
    def update_application(timer)
    end

    # specify that the scene is dirty and needs to be rerendered when you
    # make a change which does not change the scene graph in a way for it
    # to recognize it needs to be rendered.  Generally, anything which does
    # not change the spatial characteristics applies.
    def dirty_render!
      root.mark_dirty DirtyType::RenderState 
    end

    def hud
      unless @hud
	@hud = com.ardor3d.extension.ui.UIHud.new
	@hud.setup_input(canvas, physical, logical)
      end
      @hud
    end
  end
end
