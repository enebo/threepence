require 'example_base'

class ManyCollisions < ExampleBase
  java_import com.ardor3d.renderer.queue.RenderBucketType
  java_import com.ardor3d.scenegraph.hint.LightCombineMode
  java_import com.ardor3d.ui.text.BasicText

  def initialize
    super("Many collsions")
    @counter, @frames = 0.0, 0
  end

  def update_application(timer)
    @counter += timer.time_per_frame
    @frames += 1
    if @counter > 1
      @t.text = format "%0.2f FPS", @frames / @counter
      @counter = @frames = 0
    end
  end

  def init_application
    root.layout do
      cull_state :back
      basic_text(:fps, "Text") do
        at 0, 20, 0
      end
      node(:node1) do
	master = sphere(:sphere, 8, 8, 1) do
	  texture "images/ardor3d_white_256.jpg"
	  update_model_bound
	end

	behavior :rotating, Vector3(1, 1, 0.5), 50
	
	at 0, 0, -200
	200.times do
	  master.duplicate_as(:sphere) do
	    at rand*100.0 - 50, rand*100.0 - 50, rand*100.0 - 50
	  end
	end
      end.duplicate_as(:node2) do |me, original|
	me.behavior :rotating, Vector3(0.5, 1, 0.5), 50
	me.color :none, :diffuse => :yellow
	me.children.each do |child|
	  child.at rand*100.0 - 50, rand*100.0 - 50, rand*100.0 - 50
	end
	original.collides_with(me) { puts "Collision" }
	original.avoids_collision_with(me) { puts "No Collision!" }
      end
    end
    @t = root.find_child :fps
  end
end

ManyCollisions.start
