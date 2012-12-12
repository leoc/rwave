$eventmachine_library = :pure_ruby
require 'eventmachine'
require 'em-serialport'

$:.unshift './lib'
require 'rwave'

class KeyboardHandler < EM::Connection
  include EM::Protocols::LineText2

  def post_init
    prompt
  end

  def prompt
    print "> "
  end

  def receive_line line
    line.chomp!
    case(line)
    when /^on$/ then
      on
    when /^off$/ then
      off
    when /^dim (\d+)$/ then
      dim $1.to_i
    when /^exit$/ then
      EM.stop
    else
      puts line
      prompt
    end
  end
end

EM.run do
  $rwave = RWave::Port.new('/dev/ttyUSB0')

  dimmer = RWave::Node::Dimmer.new(0x02, $rwave)
  dimmer.on

  EM.add_periodic_timer(2) do
    level = Random.rand(99)
    puts "Change to #{level}%"
    dimmer.dim(level)
    puts $rwave.send_queue.inspect
  end
end
