require 'threepence/texture'

module ThreePence
  module Shape
    class SkyboxCreator
      java_import com.ardor3d.scenegraph.extension.Skybox
      def self.call(name, x, y, z, path, ext='.jpg')
        puts "in create"
        Skybox.new(name, x, y, z).tap do |s|
          s.set_texture(Skybox::Face::North, stexture(s, path + '_north' + ext))
          s.set_texture(Skybox::Face::South, stexture(s, path + '_south' + ext))
          s.set_texture(Skybox::Face::East, stexture(s, path + '_east' + ext))
          s.set_texture(Skybox::Face::West, stexture(s, path + '_west' + ext))
          s.set_texture(Skybox::Face::Up, stexture(s, path + '_up' + ext))
          s.set_texture(Skybox::Face::Down, stexture(s, path + '_down' + ext))
        end
      end

      def self.stexture(s, location)
	new_texture = s.load_texture(location, :trilinear, true)
	raise ArgumentError.new "Cannot find path: #{path}" unless new_texture
	new_texture
      end
    end
  end
end
