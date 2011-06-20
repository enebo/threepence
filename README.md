# Threepence - 3D scenegraph in Ruby

Threepence is a set of API's layered on the Ardor3d library which allows you to write hardware-accellerated 3D applications using a Ruby friendly API.

## Example

Here is a simple example showing two boxes rotating around each other while rotating themselves.  The main details to look at in this example is the root.layout DSL for laying out your scenegraph.  Also note, the behavior statements used to allow specifying declarative behavior.

<pre><code>
require 'example_base'   # See example_base.rb in samples or just use it

class Box &lt; ExampleBase
  def initialize
    super("Box Example")
  end

  def init_application
    root.layout do
      skybox(:sky, 500, 500, 500, 'images/skybox/blue')
      node(:spinning) do
        color :diffuse
        behavior :rotating, Vector3(1, 1, 0.5), 50

        box(:left_box, 1, 1, 1) do
          behavior :rotating, Vector3(0.5, 1, 1), 50
          at 0, 0, -3
          texture "images/ardor3d_white_256.jpg"
        end.duplicate_as(:right_box) do
          at 0, 0, 3
        end
      end
    end
  end
end

Box.start
</code></pre>

## DSLs

There are two DSLs which exist in Threepence.  The first is the layout DSL shown above for specifying your scenegraph.  The format of this DSL is to nest types of objects (box, sphere, etc...) in the scene and to nest the children of these objects within nested blocks (typically of type 'node').  The DSL also allows you to easily specify base attributes of the object (name, physical details, behavior).

The second DSL is for a HUD-ui.  The format of this DSL is very similiar to the layout DSL in structure.

## Running

The commandline is a little rougher than it should be for the time being.  To get started, you can run the samples:

<pre><code>
jruby -J-Djava.library.path=lib/lwjgl/native/macosx -Ilib:samples samples/simple_ui.rb
</pre></code>

where java.library.path should be changed to the directory for your particular OS.

## Futures

Ardor3d has some slated work towards making it work on Android.  This would make it possible for Threepence to run on Android as well via Ruboto.
