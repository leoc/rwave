$eventmachine_library = :pure_ruby
require 'eventmachine'
require 'em-serialport'
require 'smart_colored/extend'
require 'pry'

require 'rwave/devices/node'
require 'rwave/devices/controller'
require 'rwave/devices/switch'
require 'rwave/devices/dimmer'

require 'rwave/message'
require 'rwave/driver'
require 'rwave/manager'


module RWave
  VERSION = '0.0.1'
end
