require 'java'

# Load back-end libs
Dir[File.dirname(__FILE__) + '/*.jar'].each { |jar_file| require jar_file }
require 'lwjgl/lwjgl.jar'
require 'lwjgl/jinput.jar'

# If true we will exit at the end..no matter what!
$quit_vm_on_exit = true

module ThreePence
  LIB_LOCATION = File.dirname(__FILE__)
end

require 'threepence/application'
