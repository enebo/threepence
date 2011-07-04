module ThreePence
  module UIGoodies
    COMPONENTS = {
      'button' => com.ardor3d.extension.ui.UIButton,
      'check_box' => com.ardor3d.extension.ui.UICheckBox,
      'frame' => com.ardor3d.extension.ui.UIFrame,
      'label' => com.ardor3d.extension.ui.UILabel,
      'panel' => com.ardor3d.extension.ui.UIPanel,
      'password_field' => com.ardor3d.extension.ui.UIPasswordField,
      'progress_bar' => com.ardor3d.extension.ui.UIProgressBar,
      'radio_button' => com.ardor3d.extension.ui.UIRadioButton,
      'scroll_panel' => com.ardor3d.extension.ui.UIScrollPanel,
      'slider' => com.ardor3d.extension.ui.UISlider,
      'tabbed_pane' => com.ardor3d.extension.ui.UITabbedPane,
      'text_area' => com.ardor3d.extension.ui.UITextArea,
      'text_field' => com.ardor3d.extension.ui.UITextField
    }
  end

  module UILayoutCommon
    def button_group
      com.ardor3d.extension.ui.util.ButtonGroup.new
    end

    def layout(&code)
      if block_given?
        (code.arity == 1 ? code[self] : self.instance_eval(&code)).tap do |c|
          c.updateMinimumSizeFromContents
          c.layout
          c.pack
          c.use_standin true
        end
      end
    end

    def method_missing(type, name, *args, &code)
      instantiate_uigoodie(type, *args, &code).tap do |ui|
        ui.name = name.to_s if ui.respond_to? :name
        code.arity == 1 ? code[ui] : ui.instance_eval(&code) if block_given?
        $last_ui = ui # FIXME: Hacky, but it will work for now
        ui_add ui
      end
    end

    def instantiate_uigoodie(component, *args, &code)
      component_class = ThreePence::UIGoodies::COMPONENTS[component.to_s]
      unless component_class
	raise ArgumentError.new "No such ui component: #{component.to_s}" 
      end
      component_class.new(*args)
    end

    # To be overriden by Frame since it is not just an add
    def ui_add(component)
      add component
    end
  end
end

# extends node interestingly enough
class com::ardor3d::extension::ui::UIHud
  include ThreePence::UILayoutCommon
end

# extends node interestingly enough
class com::ardor3d::extension::ui::UIComponent
  include ThreePence::UILayoutCommon

  gesetter :enabled
  gesetter :visible
  gesetter :virgin_content_area
  gesetter :font_styles
  gesetter :layout_data, :layout_data_transformer

  alias :local_component_size :setLocalComponentSize
  alias :content_size :setContentSize

  gesetter :content_width
  gesetter :content_height
  gesetter :local_component_width
  gesetter :local_component_height
  
  alias :maximum_content_size :setMaximumContentSize

  gesetter :maximum_content_width
  gesetter :maximum_content_height

  alias :minimum_content_size :setMinimumContentSize

  gesetter :minimum_content_width
  gesetter :minimum_content_height
  gesetter :consume_key_events
  gesetter :border
  gesetter :backdrop
  gesetter :margin
  gesetter :padding

  alias :hud_xy :setHudXY

  gesetter :hud_x
  gesetter :hud_y

  alias :local_xy :setLocalXY
  
  gesetter :local_x
  gesetter :local_y
  gesetter :foreground_color
  gesetter :tooltip_text
  gesetter :tooltip_pop_time
  gesetter :default_font_family
  gesetter :default_font_size
  gesetter :default_font_styles
  gesetter :opacity
  gesetter :use_transparency
  gesetter :key_focus_target

  LAYOUT_CONSTANTS = {
    'north' => com.ardor3d.extension.ui.layout.BorderLayoutData::NORTH,
    'south' => com.ardor3d.extension.ui.layout.BorderLayoutData::SOUTH,
    'east' => com.ardor3d.extension.ui.layout.BorderLayoutData::EAST,
    'west' => com.ardor3d.extension.ui.layout.BorderLayoutData::WEST,
    'center' => com.ardor3d.extension.ui.layout.BorderLayoutData::CENTER
  }

  def layout_data_transformer(value)
    LAYOUT_CONSTANTS[value.to_s]
  end

  ALIGNMENT_CONSTANTS = {
    'top_left' => com.ardor3d.extension.ui.util.Alignment::TOP_LEFT,
    'top' => com.ardor3d.extension.ui.util.Alignment::TOP,
    'top_right' => com.ardor3d.extension.ui.util.Alignment::TOP_RIGHT,
    'middle' => com.ardor3d.extension.ui.util.Alignment::MIDDLE,
    'right' => com.ardor3d.extension.ui.util.Alignment::RIGHT,
    'bottom_left' => com.ardor3d.extension.ui.util.Alignment::BOTTOM_LEFT,
    'bottom' => com.ardor3d.extension.ui.util.Alignment::BOTTOM,
    'bottom_right' => com.ardor3d.extension.ui.util.Alignment::BOTTOM_RIGHT
  }

  def alignment_data_transformer(value)
    ALIGNMENT_CONSTANTS[value.to_s]
  end

  # Handy shortcut when using AnchorLayout
  #
  # anchor_from :top_left, :previous, :bottom_left, 0, -5
  # :previous means last encountered element.  You can also pass in a real
  # UIComponent reference when your needs are different
  def anchor_from(my_point, parent, parent_point, x_offset, y_offset)
    my_point = alignment_data_transformer(my_point)
    parent_point = alignment_data_transformer(parent_point)
    parent = $last_ui if parent == :previous
    layout_data com.ardor3d.extension.ui.layout.AnchorLayoutData.new(my_point, parent, parent_point, x_offset, y_offset)
  end
end

class com::ardor3d::extension::ui::UIFrame
  def ui_add(component)
    content_panel.add component
  end

  gesetter :resizeable
  gesetter :draggable
  gesetter :location_relative_to
  gesetter :content_panel
  gesetter :title
  gesetter :drag_listener
end

class com::ardor3d::extension::ui::AbstractLabelUIComponent
  # {G,S}ets the gap between components text and label in pixels
  gesetter :gap
end

class com::ardor3d::extension::ui::UIButton
  gesetter :selected
  gesetter :selectable
  gesetter :group

  def button_text(value=nil, is_styled=nil)
    if value.nil?
      get_button_text
    else
      if is_styled.nil?
        set_button_text value
      else
        set_button_text value, is_styled
      end
    end
  end

  gesetter :button_icon
  gesetter :action_command
end

class com::ardor3d::extension::ui::UIContainer
  gesetter :dirty
  gesetter :do_clip
  gesetter :use_standin
  gesetter :minification_filter
end

class com::ardor3d::extension::ui::UIProgressBar
  gesetter :horizontal
  gesetter :percent_filled
  gesetter :label_text
  gesetter :bar_text
end

class com::ardor3d::extension::ui::UISlider
  gesetter :value
  gesetter :model
  gesetter :snap_to_values
end
