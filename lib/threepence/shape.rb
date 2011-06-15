require 'threepence/shape/skybox'
require 'threepence/shape/basic_text'

module ThreePence
  module Shape
    # Many basic shapes require that a Vector is passed in as part
    # of the constructor.  This looks gross in the layout DSL so this
    # class is a way of hiding that (see use in NAMES_TO_SHAPES below).
    class VectorCreator
      def initialize(clazz, bounding_clazz=nil)
        @clazz, @bounding_clazz = clazz, bounding_clazz
      end

      def call(*args)
        @clazz.new(args[0], Vector3(), *args[1..-1]).tap do |instance|
          instance.model_bound = @bounding_clazz.new if @bounding_clazz
        end
      end
    end

    SC = com.ardor3d.scenegraph.shape
    B = com.ardor3d.bounding
    # TODO: Add all bounding volumes

    # All the accepted shapes in the layout DSL.  The value represents
    # a creator, which has a call method which is responsible for taking
    # the name/id/label of the particular shape to be created along with
    # all the arguments needed to make the object.  call is a somewhat
    # lame method name, but it is nice because proc's have a call method :)
    NAMES_TO_SHAPES = {
      'arrow' => VectorCreator.new(SC::Arrow),
      'axis_rods' => VectorCreator.new(SC::AxisRods),
      'basic_text' => BasicTextCreator, # shape/basic_text (-core)
      'box' => VectorCreator.new(SC::Box, B::BoundingBox),
      'capsule' => VectorCreator.new(SC::Capsule),
      'cone' => VectorCreator.new(SC::Cone),
      'cylinder' => VectorCreator.new(SC::Cylinder),
      'disk' => VectorCreator.new(SC::Disk),
      'dodecaheron' => VectorCreator.new(SC::Dodecahedron),
      'dome' => VectorCreator.new(SC::Dome),
      'extrusion' => VectorCreator.new(SC::Extrusion),
      'geo_sphere' => VectorCreator.new(SC::GeoSphere),
      'hexagon' => VectorCreator.new(SC::Hexagon),
      'icosahedron' => VectorCreator.new(SC::Icosahedron),
      'mult_face_box' => VectorCreator.new(SC::MultiFaceBox),
      'node' => proc { |name, *args| com.ardor3d.scenegraph.Node.new name },
      'octahedron' => VectorCreator.new(SC::Octahedron),
      'oriented_box' => VectorCreator.new(SC::OrientedBox),
      'pq_torus' => VectorCreator.new(SC::PQTorus),
      'pyramid' => VectorCreator.new(SC::Pyramid),
      'quad' => VectorCreator.new(SC::Quad),
      'rounded_box' => VectorCreator.new(SC::RoundedBox),
      'skybox' => SkyboxCreator,     # shape/skybox (-core)
      'sphere' => VectorCreator.new(SC::Sphere, B::BoundingSphere),
      'strip_box' => VectorCreator.new(SC::StripBox),
      'teapot' => proc { |name, *args| SC::Teapot.new name },
      'torus' => VectorCreator.new(SC::Torus),
      'tube' => VectorCreator.new(SC::Tube)
    }

    def shape(shape, name, *args, &code)
      shape_class = NAMES_TO_SHAPES[shape.to_s]
      raise ArgumentError.new "No such shape: #{shape.to_s}" unless shape_class
      node = shape_class.call(name.to_s, *args)
      code.arity == 1 ? code[node] : node.instance_eval(&code) if block_given?
      node
    end
  end
end
