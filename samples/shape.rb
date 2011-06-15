require 'example_base'

class Box < ExampleBase
  def initialize
    super("Box Example")
  end

  def init_application
    spinning = root.layout do
      skybox(:sky, 50, 50, 50, 'images/skybox/blue')
      node(:spinning) do
	at 0, 0, -3
	color :diffuse
	behavior :rotating, Vector3(1, 1, 0.5), 50
      end
    end

    # Fixme: No texture or behavior since it is not in layout
    box = root.shape(:box, :box, 1, 1, 1) do
      at 0, 0, -3
      set_random_colors
      texture "images/ardor3d_white_256.jpg"
      behavior :rotating, Vector3(1, 0.5, 1), 150
      print_spatial
    end
    spinning.attach_child box

    sphere = root.shape(:sphere, :sphere, 16, 16, 1) do
      at 0, 0, -3
      set_random_colors
      behavior :rotating, Vector3(1, 0.5, 1), 150
      texture "images/ardor3d_white_256.jpg"
    end

    hud.layout do
      frame(:frame, "Shapes") do
	panel(:panel) do
	  group = button_group
	  box_option(:radio_button) do
	    set_button_text("box", true)
	    set_selected true
	    set_group group
	    add_action_listener do 
	      spinning.detach_all_children
	      spinning.attach_child box
	    end
	  end
	  sphere_option(:radio_button) do
	    set_button_text("sphere", true)
	    set_group group
	    add_action_listener do
	      spinning.detach_all_children
	      spinning.attach_child sphere
	    end
	  end
	end
	update_minimum_size_from_contents
	layout
	pack
	set_use_standin true
      end
    end
  end
end

Box.start
