require 'example_base'

class Box < ExampleBase
  def initialize
    super("Box Example")
  end

  def init_application
    root.layout do
      cull_state :back
      skybox(:sky, 500, 500, 500, 'images/skybox/blue')
      node(:spinning) do
	behavior :rotating, Vector3(1, 1, 0.5), 50

	box(:left_box, 1, 1, 1) do
	  behavior :rotating, Vector3(0.5, 1, 1), 50
	  at 0, 0, -3
	  texture "images/ardor3d_white_256.jpg"
	end.duplicate_as(:right_box) do
	  at 0, 0, 3
	end
      end
    end
  end
end

Box.start
