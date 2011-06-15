require 'example_base'

SIZE = 400.0
DEPTH = SIZE / 32
HEIGHT = SIZE / 32
LENGTH = SIZE / 32

module Ball
  include Rotating, Explosions

  def initialize_behavior(root)
    @terrain = root.find_child(:terrain)
    @velocity, Vector3f(0, 0, 0)
    reset(10)  # Initialize ball velocity
  end
  
  def bounce
    @velocity.x *= -15
    @velocity.z += rand(2000) - 1000
    explosion
  end

  def constrain_velocity
    @velocity.x = FastMath.clamp(@velocity.x, -800.0, 800.0)
    @velocity.z = FastMath.clamp(@velocity.z, -800.0, 800.0)
  end

  def move(tpf)
    constrain_velocity
    rotate(tpf)

    # Move ball according to velocity
    local_translation.addLocal(@velocity.mult(tpf))
    local_translation.y = @terrain.getHeight(local_translation)
    local_translation.y = 0.0 if local_translation.y.nan?

    normal = @terrain.getSurfaceNormal(local_translation, @vector)
    if (normal)
      @velocity.x += normal.x * 6000.0 * tpf
      @velocity.z += normal.z * 6000.0 * tpf
    end

    @velocity.multLocal(1.0 - tpf * 0.2)
  end
  
  def reflected_bounce
    @velocity.z *= -1
  end

  def reset(velocity_magnitude = 200)
    local_translation.zero
    @velocity.set(FastMath.rand.nextFloat * velocity_magnitude, 0, 
                  FastMath.rand.nextFloat * velocity_magnitude)
  end
end

module Paddle
  MIN_Z = -Arena::SIZE + LENGTH
  MAX_Z = Arena::SIZE - LENGTH  

  attr_accessor :speed, :text

  def initialize_behavior(root)
    @score, @speed = 0, 1000.0
  end

  def move_up(tpf)
    new_z = local_translation.z - @speed * tpf
    local_translation.z = new_z < MIN_Z ? MIN_Z : new_z
  end

  def move_down(tpf)
    new_z = local_translation.z + @speed * tpf
    local_translation.z = new_z > MAX_Z ? MAX_Z : new_z
  end

  def score_goal
    @score = @score + 1
  end
end

class Terrain < TerrainPage
  def initialize
    texture_dir = "data/texture/"
    gray_scale = image_icon(texture_dir + "terrain/trough3.png")
    height_map = ImageBasedHeightMap.new gray_scale.image
    terrain_scale = Vector3f.new(6, 0.4, 6)
    height_map.set_height_scale(0.001)
    super("Terrain", 33, height_map.size + 1, terrain_scale, height_map.height_map)
    local_translation.set(0, -9.5, 0)
    setDetailTexture(1, 16)

    pst = ProceduralSplatTextureGenerator.new(height_map)
    pst.addTexture image_icon(texture_dir + "grassb.png"), -128, 0, 128
    pst.addTexture image_icon(texture_dir + "dirt.jpg"), 0, 128, 255
    pst.addTexture image_icon(texture_dir + "highest.jpg"), 128, 255, 384
    pst.addSplatTexture image_icon(texture_dir + "terrainTex.png"), image_icon(texture_dir + "water.png")
    pst.createTexture(1024)

    ts = DisplaySystem.display_system.renderer.createTextureState
    t1 = TextureManager.load_from_image(pst.image_icon.image)
    t2 = TextureManager.load(resource(texture_dir + "Detail.jpg"))
    t1.set!(:apply => Texture::ApplyMode::Combine,
                :combine_func_rgb => Texture::CombinerFunctionRGB::Modulate,
                :combine_src0_rgb => Texture::CombinerSource::CurrentTexture,
                :combine_op0_rgb => Texture::CombinerOperandRGB::SourceColor,
                :combine_src1_rgb => Texture::CombinerSource::PrimaryColor,
                :combine_op1_rgb => Texture::CombinerOperandRGB::SourceColor)
    t1.set!(:wrap => Texture::WrapMode::Repeat,
                :apply => Texture::ApplyMode::Combine,
                :combine_func_rgb => Texture::CombinerFunctionRGB::AddSigned,
                :combine_src0_rgb => Texture::CombinerSource::CurrentTexture,
                :combine_op0_rgb => Texture::CombinerOperandRGB::SourceColor,
                :combine_src1_rgb => Texture::CombinerSource::Previous,
                :combine_op1_rgb => Texture::CombinerOperandRGB::SourceColor)
    ts.setTexture(t1, 0)
    ts.setTexture(t2, 1)
    setRenderState(ts)
  end
end

class Water < WaterRenderPass
  def initialize(game)
    super(game.cam, 2, false, false)
    set!(:water_plane => Plane.new(Vector3f.new(0.0, 1.0, 0.0), 0.0), 
             :clip_bias => -1.0, :reflection_throttle => 0.0, :refraction_throttle => 0.0)

    @waterQuad = Quad.new("waterQuad", 1, 1)
    @waterQuad.normal_buffer.reset_to(0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0)
    setWaterEffectOnSpatial(@waterQuad)
    
    game.root_node << @waterQuad

    setReflectedScene(game.sky)
    addReflectedScene(game.arena)
    setSkybox(game.sky)
  end

  def update(cam, far_plane)
    transVec = Vector3f.new(cam.location.x, water_height, cam.location.z)
    setTextureCoords(0, transVec.x, -transVec.z, 0.07, far_plane)
    setVertexCoords(transVec.x, transVec.y, transVec.z, far_plane)
  end

  def setVertexCoords(x, y, z, far_plane)
    @waterQuad.vertex_buffer.reset_to(x - far_plane, y, z - far_plane,
                                      x - far_plane, y, z + far_plane,
                                      x + far_plane, y, z + far_plane,
                                      x + far_plane, y, z - far_plane)
  end

  def setTextureCoords(buffer, x, y, texture_scale, far_plane)
    x = x * texture_scale * 0.5
    y = y * texture_scale * 0.5
    texture_scale = far_plane * texture_scale
    @waterQuad.texture_coords(buffer).coords.reset_to(x, texture_scale + y, x, y,
       texture_scale + x, y, texture_scale + x, texture_scale + y)
  end
end

class Main < ExampleBase
  attr_reader :sky, :arena
  ORIGIN = Vector3f.new 0, 0, 0
  FAR_PLANE = 20000.0
  
  def initialize
    super("King Pong")
  end

  def init_lighting
    light_state.attach DirectionalLight.new.set!(:enabled => true,
      :diffuse => ColorRGBA.new(1, 1, 1, 1), :ambient => ColorRGBA.new(0.5, 0.5, 0.7, 1),
      :direction => Vector3f.new(-0.8, -1.0, -0.8))
  end

  def init_application
    root.layout do
      node(:arena) do
	texture "images/rockwall2.jpg"
	location 0, 0, 0

	node(:side_walls) do
	  box(:side_wall, ARENA_SIZE+ARENA_SIZE / 12 + DEPTH, HEIGHT, LENGTH) do
	    at 0, 0, SIZE
	  end.duplicate_as(:side_wall) do
            at 0, 0, -SIZE
          end
	end

	node(:goal_walls) do
	  box(:goal_wall, DEPTH, HEIGHT, LENGTH) do
	    at ARENA_SIZE + ARENA_SIZE / 12, 0, 0
	  end.duplicate_as(:goal_wall) do
            at -ARENA_SIZE - ARENA_SIZE / 12, 0, 0
          end
	end

	sphere(:ball, 16.samples, 16.samples, 25) do
	  texture "images/monkey.jpg"
	  behavior Ball
	end

	box(:paddle, SIZE/24, SIZE/12, SIZE/6) do
	  at -SIZE, 0, 0
	  behavior Paddle
	end.duplicate_as(:paddle2) do
          at SIZE, 0, 0
        end
	skybox(:sky, 10, 10, 10 'images/skybox/blue')
      end
    end

    add_trigger(G.pressed) { @ball.reset }
    add_trigger(ONE.held) { |s, i, tpf| @paddle1.move_up tpf }
    add_trigger(TWO.held) { |s, i, tpf| @paddle1.move_down tpf }
    add_trigger(NINE.held) { |s, i, tpf| @paddle2.move_up tpf }
    add_trigger(ZERO.held) { |s, i, tpf| @paddle2.move_down tpf }
    @ball.collides_with(@paddle1) { @ball.bounce }
    @ball.collides_with(@paddle2) { @ball.bounce }
    @ball.collides_with(@side_walls) { @ball.reflected_bounce }
    @ball.collides_with(@goal_walls) { @ball.reset }

    @sky = Sky.new
    terrain = Terrain.new
    root_node.updateGeometricState(0.0, true)
    root_node.updateRenderState
    root_node.cull_hint = Spatial::CullHint::Never
    
    @water = Water.new(self)    
    pass_manager << @water << root_node
  end

  def update_application
    @sky.update(cam)
    @water.update(cam, FAR_PLANE)
    @ball.move tpf
  end
end

Main.new.start
