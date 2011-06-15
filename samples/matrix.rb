require 'example_base'

class Matrix < ExampleBase
  def initialize
    super("Matrix Example")
    @boxes, @time = [], 0.0
    @up = Vector3(0, 1, 0)
  end

  def init_application
    canvas.canvas_renderer.camera.location = Vector3(0, 0, 140)
    boxes = @boxes
    box = root.shape(:box, :box, 1, 1, 4)
    root.layout do
      sphere(:target, 8, 8, 2) do
	at 0, 5, 10
	update_model_bound
	set_random_colors
      end
      
      0.upto(9) do |x|
	0.upto(9) do |y|
	  boxes << box.duplicate_as("box #{x}, #{y}", self) do
	    at (x - 5) * 10.0, (y - 5) * 10.0, -10.0
	  end
	end
      end

      texture "images/ardor3d_white_256.jpg"
      color :diffuse
    end

    @target = root.find_child(:target)
  end

  def update_application(timer)
    @time += timer.time_per_frame
    @target.at!(Math.sin(@time) * 20, Math.cos(@time * 1.4) * 20, 0)
    @boxes.each { |box| box.look_at(@target, @up) }
  end
end

Matrix.start
