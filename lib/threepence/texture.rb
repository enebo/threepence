module ThreePence
  java_import com.ardor3d.util.TextureManager

  module Texture
    def load_texture(location, min_filter=:trilinear, draw_vertically=false)
      minification = texture_minification(min_filter)
      TextureManager.load(location, minification, draw_vertically)
    end

    def texture_minification(value)
      min_filter = com.ardor3d.image.Texture::MinificationFilter

      case value
      when :nearest_neighbor_no then
	min_filter::NearestNeighborNoMipMaps
      when :bilinear_no then
	min_filter::BilinearNoMipMaps
      when :nearest_neighbor_nearest then
	min_filter::NearestNeighborNearestMipMap
      when :bilinear_nearest then
	min_filter::BilinearNearestMipMap
      when :nearest_neighbor_linear then
	min_filter::NearestNeighborLinearMipMap
      when :trilinear then
	min_filter::Trilinear
      else
	raise ArgumentError.new "Invalid minification speficied: #{value}"
      end
    end
  end
end
