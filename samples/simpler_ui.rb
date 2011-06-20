require 'example_base'

java_import com.ardor3d.extension.ui.layout.BorderLayout
java_import com.ardor3d.extension.ui.layout.BorderLayoutData

# Illustrates how to display GUI primitives on a canvas.
class SimplerUIExample < ExampleBase
  def initialize
    super("Simple UI Example")
    @counter, @frames = 0.0, 0
  end

  def init_application
    root.layout do
      box(:box, 5, 5, 5) do
	behavior :rotating, Vector3(1, 1, 0.5), 50
	at 0, 0, -25
	texture "images/ardor3d_white_256.jpg"
      end
    end

    hud.layout do
      frame(:frame, "0000 FPS ") do
        panel(:buttons, BorderLayout.new) do
          layout_data :center
          button(:button_n, "Button North") do
            gap 10
            layout_data :center
            tooltip_text "This is a tooltip!"
          end
        end
      end
    end
  end

  def update_application(timer)
    @counter += timer.time_per_frame
    @frames += 1
    if @counter > 1
      hud.find_child(:frame).title = "#{(@frames / @counter).round} UPS"
      @counter, @frames = 0.0, 0
    end
    @hud.updateGeometricState timer.time_per_frame
  end
end

ExampleBase.start(SimplerUIExample)
