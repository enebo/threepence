module Kernel
  def Vector2(x=0, y=0)
    com.ardor3d.math.Vector2.new x, y
  end

  def Vector3(x=0, y=0, z=0)
    com.ardor3d.math.Vector3.new x, y, z
  end

  def Matrix3()
    com.ardor3d.math.Matrix3.new
  end
end

