require 'example_base'

class Cubes < ExampleBase
  DIM = 64
  def initialize
    super("Cubes")
  end

  def init_application
    canvas.canvas_renderer.camera.location = Vector3(1, 1, 3)
    boxes = @boxes
    box = root.shape(:box, :box, 1, 1, 1) do
      model_bound(com.ardor3d.bounding.BoundingBox.new)
    end
    puts "Time #{Time.now}"
    root.layout do
      0.upto(DIM-1) do |i|
	0.upto(DIM-1) do |j|
	  0.upto(DIM-1) do |k|
	    box.duplicate_as("box #{i}, #{j}", self) do
	      at 2*i, 2*j, -2*k
	    end
	  end
	end
      end

      texture "images/ardor3d_white_256.jpg"
      color :diffuse
    end

    cull_state = com.ardor3d.renderer.state.CullState.new.tap do |state|
      state.cull_face = com.ardor3d.renderer.state.CullState::Face::Back
      state.enabled = true
    end
    root.set_render_state cull_state

    zbuf = com.ardor3d.renderer.state.ZBufferState.new.tap do |buf|
      buf.setEnabled(true)
      buf.setFunction(com.ardor3d.renderer.state.ZBufferState::TestFunction::LessThanOrEqualTo)
    end
    root.setRenderState(zbuf)


    puts "Time(done) #{Time.now}"
  end
end

Cubes.start
