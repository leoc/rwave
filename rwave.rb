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
    when /^add (\w+) (\d+) (\w+)$/ then
      klass = RWave::Node.const_get("#{$1.capitalize}")
      $nodes[$3.downcase] = klass.new($2.to_i, $rwave)
    when /^rm (\w+)$/ then
      $nodes.delete($1.downcase)
    when /^(\w+) on$/ then
      $nodes[$1.downcase].on
    when /^(\w+) off$/ then
      $nodes[$1.downcase].off
    when /^(\w+) dim (\d+)$/ then
      $nodes[$1.downcase].dim $2.to_i
    when /^start random on (\w+)$/ then
      $timer = EM.add_periodic_timer(2) do
        level = Random.rand(99)
        $nodes[$1.downcase].dim(level)
      end
    when /^stop random$/ then
      $timer.cancel
    when /^exit$/ then
      EM.stop
    end
  end
end

EM.run do
  $rwave = RWave::Port.new('/dev/ttyUSB0')
  $nodes = {}

  EM.open_keyboard KeyboardHandler
end
