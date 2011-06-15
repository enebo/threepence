module ThreePence
  module Behavior
    class Rotating
      include com.ardor3d.scenegraph.controller.SpatialController

      def initialize(axis_of_rotation, speed)
	@axis, @speed = axis_of_rotation.normalize_local, speed
	@rotate, @angle = com.ardor3d.math.Matrix3.new, 0.0
      end

      def update(time, caller)
	@angle = (@angle + time * @speed) % 360
	@rotate.fromAngleNormalAxis(@angle * com.ardor3d.math.MathUtils::DEG_TO_RAD, @axis)
	caller.rotation = @rotate
      end
    end
  end
end
