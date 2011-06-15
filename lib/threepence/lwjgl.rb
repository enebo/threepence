module ThreePence
  java_import com.ardor3d.framework.lwjgl.LwjglCanvas
  java_import com.ardor3d.framework.lwjgl.LwjglCanvasRenderer
  java_import com.ardor3d.input.PhysicalLayer
  java_import com.ardor3d.input.lwjgl.LwjglControllerWrapper
  java_import com.ardor3d.input.lwjgl.LwjglKeyboardWrapper
  java_import com.ardor3d.input.lwjgl.LwjglMouseManager
  java_import com.ardor3d.input.lwjgl.LwjglMouseWrapper
  java_import com.ardor3d.renderer.TextureRendererFactory
  java_import com.ardor3d.renderer.lwjgl.LwjglTextureRendererProvider

  class LWJGL
    def self.setup(application, settings)
      canvas_renderer = LwjglCanvasRenderer.new(application)
      canvas = LwjglCanvas.new(canvas_renderer, settings)
      physical = PhysicalLayer.new(LwjglKeyboardWrapper.new, 
				   LwjglMouseWrapper.new, 
				   LwjglControllerWrapper.new, 
				   canvas)
      mouse_manager = LwjglMouseManager.new
      TextureRendererFactory::INSTANCE.setProvider(LwjglTextureRendererProvider.new)
      [canvas, physical, mouse_manager]
    end
  end
end
