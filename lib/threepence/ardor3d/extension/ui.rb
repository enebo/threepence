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
      code.arity == 1 ? code[self] : self.instance_eval(&code) if block_given?
    end

    def method_missing(name, type, *args, &code)
      ui = instantiate_uigoodie(type, *args, &code)
      ui.name = name.to_s if ui.respond_to? :name

      code.arity == 1 ? code[ui] : ui.instance_eval(&code) if block_given?
      ui_add ui
      ui
    end

    def instantiate_uigoodie(component, *args, &code)
      component_class = ThreePence::UIGoodies::COMPONENTS[component.to_s]
      unless component_class
	raise ArgumentError.new "No such ui component: #{component.to_s}" 
      end
      puts "ARGS #{args}"
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
end

class com::ardor3d::extension::ui::UIFrame
  def ui_add(component)
    set_content_panel component
  end
end
