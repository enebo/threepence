require 'example_base'

java_import com.ardor3d.bounding.BoundingBox
java_import com.ardor3d.extension.ui.Orientation
java_import com.ardor3d.extension.ui.UIButton
java_import com.ardor3d.extension.ui.UICheckBox
java_import com.ardor3d.extension.ui.UIComponent
java_import com.ardor3d.extension.ui.UIFrame
java_import com.ardor3d.extension.ui.UIHud
java_import com.ardor3d.extension.ui.UILabel
java_import com.ardor3d.extension.ui.UIPanel
java_import com.ardor3d.extension.ui.UIPasswordField
java_import com.ardor3d.extension.ui.UIProgressBar
java_import com.ardor3d.extension.ui.UIRadioButton
java_import com.ardor3d.extension.ui.UIScrollPanel
java_import com.ardor3d.extension.ui.UISlider
java_import com.ardor3d.extension.ui.UITabbedPane
java_import com.ardor3d.extension.ui.UITextArea
java_import com.ardor3d.extension.ui.UITextField
java_import com.ardor3d.extension.ui.backdrop.MultiImageBackdrop
java_import com.ardor3d.extension.ui.event.ActionEvent
java_import com.ardor3d.extension.ui.event.ActionListener
java_import com.ardor3d.extension.ui.layout.BorderLayout
java_import com.ardor3d.extension.ui.layout.BorderLayoutData
java_import com.ardor3d.extension.ui.layout.GridLayout
java_import com.ardor3d.extension.ui.layout.GridLayoutData
java_import com.ardor3d.extension.ui.layout.RowLayout
java_import com.ardor3d.extension.ui.util.Alignment
java_import com.ardor3d.extension.ui.util.ButtonGroup
java_import com.ardor3d.extension.ui.util.Dimension
java_import com.ardor3d.extension.ui.util.SubTex
java_import com.ardor3d.extension.ui.util.TransformedSubTex
java_import com.ardor3d.image.Texture
java_import com.ardor3d.math.ColorRGBA
java_import com.ardor3d.math.MathUtils
java_import com.ardor3d.math.Matrix3
java_import com.ardor3d.math.Quaternion
java_import com.ardor3d.math.Vector2
java_import com.ardor3d.math.Vector3
java_import com.ardor3d.renderer.Renderer
java_import com.ardor3d.renderer.state.TextureState
java_import com.ardor3d.scenegraph.shape.Box
java_import com.ardor3d.util.ReadOnlyTimer
java_import com.ardor3d.util.TextureManager

# Illustrates how to display GUI primitives on a canvas.
class SimpleUIExample < ExampleBase
  def initialize
    super("Simple UI Example")
    @counter, @frames = 0, 0
  end

  def init_application
    UIComponent.setUseTransparency(true)

    root.layout do
      box(:box, 5, 5, 5) do
	behavior :rotating, Vector3(1, 1, 0.5), 50
	at 0, 0, -25
	texture "images/ardor3d_white_256.jpg"
      end
    end

    timer = @timer
    cr = canvas_renderer
    frame = nil
    hud.layout do
      frame(:frame, "UI Sample: 0000 FPS ") do
	tabbed_pane(:tabs, UITabbedPane::TabPlacement::NORTH) do
	  panel(:widgets, BorderLayout.new) do
	    #	  color :dark_gray
	    button(:button_a, "Button A") do
	      #	    icon(26, 20, texture("images/ardor3d_white_256.jpg"))
	      gap 10
	      layout_data :north
	      tooltip_text "This is a tooltip!"
	    end
	    panel(:center) do
	      layout_data :center
	      check_box(:check1, "Hello\n(disabled)") do
		selected true
		enabled false
	      end
	      check_box(:check2, "World")
	      group = button_group
	      radio_button(:radio1) do
		button_text "option [i]A[/i]", true
		group group
	      end
	      radio_button(:radio2) do
		button_text "option [c=#f00]B[/c]", true
		group group
	      end
	      slider = slider(:slider, Orientation::Horizontal, 0, 12, 0) do
		snap_to_values true
		minimum_content_width 100
	      end
	      label(:lslider, "0") do
		layout_data GridLayoutData::SpanAndWrap(2)
		slider.add_action_listener { self.text = slider.value.to_s}
	      end
	      progress_bar(:progress_bar, "Loading: ", true) do
		percent_filled 0
		local_component_width 250
		maximum_content_width get_content_width
		add_controller do |time, caller|
		  caller.percent_filled = timer.time_in_seconds / 15
		end
	      end
	    end
	  end
	end
      end
    end

    @frame = hud.find_child :frame

    @frame.updateMinimumSizeFromContents
    @frame.layout
    @frame.pack
    @frame.use_standin true
    @frame.opacity 1
    @frame.location_relative_to cr.camera

#    panel = makeWidgetPanel
#    panel2 = makeLoginPanel
#    panel3 = makeChatPanel
#    panel4 = makeClockPanel
#    panel5 = makeScrollPanel

#    pane = UITabbedPane.new(UITabbedPane::TabPlacement::NORTH)
#    pane.add(panel, "widgets")
#    pane.add(panel2, "grid")
#    pane.add(panel3, "chat")
#    pane.add(panel4, "clock")
#    pane.add(panel5, "picture")
  end

  def makeLoginPanel
    pLogin = UIPanel.new(GridLayout.new)
    lHeader = UILabel.new("Welcome! Log in to server xyz")
    lHeader.setLayoutData(GridLayoutData.new(2, true, true))
    lName = UILabel.new("Name")
    tfName = UITextField.new
    tfName.setText("player1")
    tfName.setLayoutData(GridLayoutData.WrapAndGrow)
    lPassword = UILabel.new("Password")
    tfPassword = UIPasswordField.new
    tfPassword.setLayoutData(GridLayoutData.WrapAndGrow)
    btLogin = UIButton.new("login")
    btLogin.addActionListener do |event|
      puts "login as user: #{tfName.getText} password: #{tfPassword.getText}"
    end
    pLogin.add(lHeader)
    pLogin.add(lName)
    pLogin.add(tfName)
    pLogin.add(lPassword)
    pLogin.add(tfPassword)
    pLogin.add(btLogin)
    return pLogin
  end

  def makeChatPanel
    chatPanel = UIPanel.new(BorderLayout.new)
    bottomPanel = UIPanel.new(BorderLayout.new)
    bottomPanel.setLayoutData(BorderLayoutData::SOUTH)
    dirLabel = UILabel.new("Sample chat.  Try using markup like [b]text[/b]:")
    dirLabel.setLayoutData(BorderLayoutData::NORTH)
    historyArea = UITextArea.new
    historyArea.setStyledText(true)
    historyArea.setAlignment(Alignment::BOTTOM_LEFT)
    historyArea.setEditable(false)
    scrollArea = UIScrollPanel.new(historyArea)
    scrollArea.setLayoutData(BorderLayoutData::CENTER)
    chatField = UITextField.new
    chatField.setLayoutData(BorderLayoutData::CENTER)
    chatButton = UIButton.new("SAY")
    chatButton.setLayoutData(BorderLayoutData::EAST)

    actionListener = proc do |event|
      applyChat(historyArea, chatField)
    end
    chatButton.addActionListener(actionListener)
    chatField.addActionListener(actionListener)

    bottomPanel.add(chatField)
    bottomPanel.add(chatButton)

    chatPanel.add(dirLabel)
    chatPanel.add(scrollArea)
    chatPanel.add(bottomPanel)
    return chatPanel
  end

  def applyChat(historyArea, chatField)
    text = chatField.getText
    if (text.length > 0)
      historyArea.setText(historyArea.getText + "\n" + text)
      chatField.setText("")
    end
  end

#   def makeClockPanel
#     ui.layout do
#       clock_panel(:panel) do
# 	set_backdrop(MultiImageBackdrop.new(ColorRGBA::BLACK_NO_ALPHA))

#     clockTex = TextureManager.load("images/clock.png", Texture::MinificationFilter::Trilinear, false)

#     clockBack = TransformedSubTex.new(SubTex.new(clockTex, 64, 65, 446, 446))

#     scale = 0.333
#     clockBack.setPivot(Vector2.new(0.5, 0.5))
#     clockBack.getTransform.setScale(scale)
#     clockBack.setAlignment(Alignment::MIDDLE)
#     clockBack.setPriority(0)
#     multiImgBD.addImage(clockBack)

#     hour = TransformedSubTex.new(SubTex.new(clockTex, 27, 386, 27, 126))
#     hour.setPivot(Vector2.new(0.5, 14 / 126.0))
#     hour.getTransform.setScale(scale)
#     hour.setAlignment(Alignment::MIDDLE)
#     hour.setPriority(1)
#     multiImgBD.addImage(hour)

#     minute = TransformedSubTex.new(SubTex.new(clockTex, 0, 338, 27, 174))
#     minute.setPivot(Vector2.new(0.5, 14 / 174.0))
#     minute.getTransform.setScale(scale)
#     minute.setAlignment(Alignment::MIDDLE)
#     minute.setPriority(2)
#     multiImgBD.addImage(minute)

#     clockPanel.addController do |time, caller|
#       angle1 = @timer.getTimeInSeconds % MathUtils::TWO_PI
#       angle2 = (@timer.getTimeInSeconds / 12.0) % MathUtils::TWO_PI

#       minute.getTransform.setRotation(Quaternion.new.fromAngleAxis(angle1, Vector3::NEG_UNIT_Z))
#       hour.getTransform.setRotation(Quaternion.new.fromAngleAxis(angle2, Vector3::NEG_UNIT_Z))
#       clockPanel.fireComponentDirty
#     end

#     return clockPanel
#   end

#   def makeScrollPanel
#     tex = TextureManager.load("images/clock.png", Texture::MinificationFilter::Trilinear, false)
#     comp = UILabel.new("")
#     comp.setIcon(SubTex.new(tex))
#     comp.updateIconDimensionsFromIcon
#     panel = UIScrollPanel.new(comp)
#     return panel
#   end

  def update_application(timer)
    @counter += timer.getTimePerFrame
    @frames += 1
    if (@counter > 1)
      fps = (@frames / @counter.to_f)
      @counter = 0
      @frames = 0
      @frame.setTitle("UI Sample: #{java.lang.Math.round(fps)} FPS")
    end
    @hud.updateGeometricState(timer.getTimePerFrame)
  end
end

ExampleBase.start(SimpleUIExample)
