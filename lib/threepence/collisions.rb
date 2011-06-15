# FIXME: No global...perhaps ardor3d has somethig for this
$collisions = []

module ThreePence
  # TODO: This is inefficient since all nodes which have different behaviors
  # but the rely on the same collision calculation should only be done once.
  module Collisions
    def collides_with(other, check_primitives=false, &code)
      $collisions << [self, other, check_primitives, code, true]
    end

    def avoids_collision_with(other, check_primitives=false, &code)
      $collisions << [self, other, check_primitives, code, false]
    end
  end

  module CollisionExecutor
    java_import com.ardor3d.intersection.PickingUtil

    def dispatch_collisions
      $collisions.each do |node1, node2, check_primitives, code, collides|
	collision = PickingUtil.has_collision node1, node2, check_primitives
	if (collides && collision) || (!collides && !collision)
	  code.call node1, node2
	end
      end
    end
  end
end
