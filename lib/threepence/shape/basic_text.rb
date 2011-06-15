require 'threepence/texture'

module ThreePence
  module Shape
    class BasicTextCreator
      java_import com.ardor3d.ui.text.BasicText
      java_import com.ardor3d.renderer.queue.RenderBucketType
      java_import com.ardor3d.renderer.queue.RenderBucketType
      java_import com.ardor3d.scenegraph.hint.LightCombineMode

      def self.call(name=nil, text=nil, font="arial-18-bold.fnt", size=18)
        BasicText.new(name, text,load_font(font), size).tap do |text|
          text.scene_hints.tap do |hints|
            render_bucket_type = RenderBucketType::Ortho
            light_combine_mode = LightCombineMode::Off
          end
        end
      end

      def self.load_font(path)
	# FIXME: Determine full path versus default paths (default only now)
	url = java.net.URL.new "file:#{ThreePence::LIB_LOCATION}/font"
	sr = SimpleResourceLocator.new url
	resource = sr.locate_resource(path)
	puts "A.4 #{resource} #{path} #{url}"
#	resource = com.ardor3d.util.resource.URLResourceSource.new url
	com.ardor3d.ui.text.BMFont.new(resource, true)
      end
    end
  end
end
