require 'example_base'

java_import com.ardor3d.extension.ui.UITabbedPane
java_import com.ardor3d.extension.ui.layout.BorderLayout

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
          button(:button_n, "North") do
            gap 10
            layout_data :north
            tooltip_text "North tooltip!"
          end
          button(:button_n, "South") do
            gap 10
            layout_data :south
            tooltip_text "South tooltip!"
          end
          button(:button_n, "East") do
            gap 10
            layout_data :east
            tooltip_text "East tooltip!"
          end
          button(:button_n, "West") do
            gap 10
            layout_data :west
            tooltip_text "West tooltip!"
          end
          button(:button_n, "Center") do
            gap 10
            layout_data :center
            tooltip_text "Center tooltip!"
          end
        end
        pack
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
