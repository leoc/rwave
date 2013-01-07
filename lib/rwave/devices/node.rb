module RWave
  class Node
    def initialize node_id, manager
      @node_id = node_id
      @driver = driver

      @driver.on_message do |sent, received|
        puts "call handler for 0x#{@node_id.to_s(16)}: #{received}"
        unless received.ack? or received.length <= 2
          case received.bytes[2]
          when 0x00 then on_request(sent, received)
          when 0x01 then on_response(sent, received)
          end
        end
      end
    end

    def get_callback_id
      @driver.get_callback_id
    end

    def send_message bytes, options = {}
      message = Message.new bytes, options
      @callback_ids << options[:callback_id] if options[:callback_id]
      @driver.enqueue_message message
    end

    def messenging_complete! callback_id = nil
      @callback_ids.delete callback_id
      @driver.messenging_complete!
    end

    def on_response(sent, received)
      # stub for subclasses
    end

    def on_request(sent, received)
      # stub for subclasses
    end
  end
end
