require 'threepence/shape'

class com::ardor3d::scenegraph::Node
  include ThreePence::Shape

  # Layout the scenegraph based on the provided block of code.
  def layout(&code)
    if block_given?
      code.arity == 1 ? code[self] : self.instance_eval(&code)
    end
  end

  def method_missing(shape_type, *args, &code)
    shape(shape_type, *args, &code).tap { |node| attach_child node }
  end

  def print_tree(indent="")
    puts "#{indent}node: #{name ? name : '(unnamed)'}"
    print_tree_body(indent)
    children.each { |child| child.print_tree(indent + "  ") }
  end

  def print_tree_body(indent="")
    h = "#{indent}#{indent}hint: "
    puts "#{h}#{scene_hints.to_s.split("\n").join("\n#{h}")}"
    super(indent)
  end

  # Looks for a child node/spatial based on it's name. 
  def find_child(name)
    get_child(name.to_s)
  end
end
