module ThreePence
  module CullState
    def cull_state(face_value = :front_and_back)
      com.ardor3d.renderer.state.CullState.new.tap do |cs|
        cs.cull_face = cull_state_face(face_value)
        set_render_state cs
      end
    end

    def cull_state_face(value)
      case value.to_s
      when 'none' then
        com.ardor3d.renderer.state.CullState::Face::None
      when 'front' then
        com.ardor3d.renderer.state.CullState::Face::Front
      when 'back' then
        com.ardor3d.renderer.state.CullState::Face::Back
      when 'front_and_back' then
        com.ardor3d.renderer.state.CullState::Face::FrontAndBack
      else
        raise ArgumentError.new "Illegal cull state: #{value}"
      end
    end
    private :cull_state_face
  end
end
