require 'example_base'

java_import com.ardor3d.example.benchmark.ball.BallComponent
java_import com.ardor3d.extension.ui.backdrop.SolidBackdrop
java_import com.ardor3d.extension.ui.layout.AnchorLayout
java_import com.ardor3d.extension.ui.layout.AnchorLayoutData
java_import com.ardor3d.extension.ui.util.Alignment
java_import com.ardor3d.extension.ui.util.ButtonGroup
java_import com.ardor3d.extension.ui.util.SubTex
java_import com.ardor3d.image.Texture
java_import com.ardor3d.image.TextureStoreFormat
java_import com.ardor3d.math.ColorRGBA
java_import com.ardor3d.ui.text.BasicText
java_import com.ardor3d.util.TextureManager

# Re-open existing Java class to add (adorn) useful method).
class BallComponent
  def collides?(other)
    ball.do_collide(other.ball)
  end
end

# The famous BubbleMark UI test, recreated using Ardor3D UI components.
class BubbleMark < ExampleBase
  BALL_SIZE = 52

  def initialize
    super("Bubble Mark")
  end

  def init_application
    @skip_ball_collide = false
    @frames = 0
    @balls = []
    @start_time = Time.now  # Use Ruby version when it is nicer

    cam = canvas.canvas_renderer.camera

    hud.layout do
      frame(:bubbles, "Bubbles") do
        update_minimum_size_from_contents
        pack 500, 300
        layout
        resizeable false
        hud_xy 5, 5
        use_standin = false
        content_panel.backdrop = SolidBackdrop.new(ColorRGBA::WHITE)
      end
      frame(:config, "Config") do
        update_minimum_size_from_contents
        pack 320, 240
        use_standin = true
        hud_xy cam.width - local_component_width - 5, cam.height - local_component_height - 5
        content_panel.layout = AnchorLayout.new
        previous = content_panel
        check_box(:vsync, "Enabled VSync") do
          anchor_from :top_left, previous, :top_left, 5, -5
          selectable = true
          add_action_listener { |event| canvas.vsync_enabled = selected? }
        end
        check_box(:collide, "Enable ball-ball collision") do
          anchor_from :top_left, :previous, :bottom_left, 0, -5
          selectable true
          selected !@skip_ball_collide
          addActionListener { |event| @skip_ball_collide = !collide.selected? }
        end
        previous = label(:balls_label, "# of balls:") do
          anchor_from :top_left, :previous, :bottom_left, 0, -15
        end
        group = button_group
        ["16", "32", "64", "128"].each do |n|
          radio_button("balls#{n}", n) do
            anchor_from :top_left, :previous, :bottom_left, 0, -5
            selectable true
            selected true
            addActionListener { |event| resetBalls(number) }
            group group
          end
        end
        layout
      end
    end
    @ball_frame = hud.find_child :bubbles

    resetBalls(16)
  end

  def resetBalls(ball_count)
    container = @ball_frame.content_panel
    container.layout = nil
    container.detach_all_children

    @balls = []

    # Create a texture for our balls to use.
    tex = SubTex.new(TextureManager.load("images/ball.png",
                                         Texture::MinificationFilter::NearestNeighborNoMipMaps, TextureStoreFormat::GuessCompressedFormat, true))

    # Add balls
    ball_count.times do |i|
      ballComp = BallComponent.new("ball", tex, BALL_SIZE, BALL_SIZE, container.content_width, container.content_height)
      container.add(ballComp)
      @balls << ballComp
    end

    @ball_frame.title = " fps"
  end

  def updateExample(timer)
    now = Time.now # use the Ruby core libs when you want too
    dt = now - @start_time

    if dt.to_f > 2.0
      @ball_frame.title = "#{(@frames / dt).round} fps"
      @start_time = now
      @frames = 0
    end

    unless @skip_ball_collide
      length = @balls.length
      length.times do |i|
        (length - i - 1).times do |j|
          @balls[i].collides? @balls[i + j + 1]
        end
      end
    end

    @frames += 1
  end
end

BubbleMark.start
