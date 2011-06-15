class com::ardor3d::scenegraph::hint::SceneHints
  def to_s
    <<-EOS
data_mode: #{local_data_mode},#{data_mode}
normals_mode: #{local_normals_mode},#{normals_mode}
cull_hint: #{local_cull_hint},#{cull_hint}
light_combine_mode: #{local_light_combine_mode},#{light_combine_mode}
texture_combine_mode: #{local_texture_combine_mode},#{texture_combine_mode}
render_bucket_type: #{local_render_bucket_type},#{render_bucket_type}
ortho_order: #{ortho_order}
    EOS
# TODO: Add picking hints
  end
end
