require 'threepence/texture'
require 'threepence/collisions'
require 'threepence/color'
require 'threepence/cull_state'

# Class for things like both.  Things which have a size.
class com::ardor3d::scenegraph::Spatial
  include ThreePence::Texture, ThreePence::Collisions, ThreePence::CullState
  include ThreePence::Color

  def print_spatial
    puts "Name: #{name}"
    puts "Controllers: #{controllers.to_a.join(", ")}"
  end

  def render_state=(value)
    set_render_state(value)
  end

  def behavior(type, *init_args)
    if type.kind_of? Symbol   # Builtin Behavior
      type = ThreePence::Behavior.const_get(type.to_s.capitalize) 
    end
    # The behavior must implement SpatialController
    add_controller type.new(*init_args)
  end

  def print_tree(indent="")
    puts "#{indent}spatial: #{name ? name : '(unnamed)'}"
    print_tree_body(indent)
  end

  def print_tree_body(indent="")
    h = "#{indent}#{indent}r_state: "
    puts(h + local_render_states.inject([]) do |sum, (state_type, state)|
           sum << "#{state_type.toString.downcase}: #{state.toString}"
           sum
         end.join("\n#{h}"))
  end

  def texture(location, min_filter=:trilinear, draw_vertically=false)
    setRenderState(com.ardor3d.renderer.state.TextureState.new.tap do |ts|
      ts.texture = load_texture location, min_filter, draw_vertically
    end)
  end

  def duplicate_as(name, parent=nil, &code)
    self.make_copy(true).tap do |node|
      node.name = name.to_s
      if block_given?
	case code.arity
 	when 0, -1 then
 	  node.instance_eval &code
 	when 1 then
 	  code[node]
 	else
 	  code[node, self]
 	end
       end
      parent = parent ? parent : self.parent
      parent.attach_child node
    end
  end

  ##
  # Get or set the location of this spatial
  #
  # box.at #=> Vector3f
  # box.at 3, 0, -1 #=> Create new vector and set location to that
  # box.at Vector3(1, 2, 3) #=> Set location and use vector that is passed in
  #
  # @see_also at!(x,y,z)
  def at(vec_or_x=nil, y=nil, z=nil)
    return get_translation unless vec_or_x

    if y && z
      set_translation com.ardor3d.math.Vector3.new(vec_or_x, y, z)
    else
      set_translation(vec_or_x)
    end
  end

  ##
  # Change translation values without creating a new matrix instance
  def at!(x, y, z)
    set_translation(get_translation.tap { |l| l.set(x, y, z) })
  end

  def look_at(at, up)
    @rotation_matrix ||= com.ardor3d.math.Matrix3.new
    com.ardor3d.math.MathUtils.matrix_look_at(get_world_translation, at.at, up, @rotation_matrix)
    set_rotation @rotation_matrix
  end
end
