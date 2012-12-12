module RWave
  class Node
    class Dimmer < Node
      def on
        set_value 0xFF
      end

      def off
        set_value 0x00
      end

      def dim(level)
        if level >= 0 and level <= 100
          set_value level
        end
      end

      def on_request sent, received
        puts
        puts "Node-Handler received #{received}"
        if received.length > 4
          case received.bytes[3]
          when 0x13
            puts "Currently running callback_ids: "+ @callback_ids.inspect
            callback_id = received.bytes[4]
            if @callback_ids.include?(callback_id)
              messenging_complete!(callback_id)
            end
          end
        end
      end

    private
      def set_value val
        puts
        puts "Setting value for node 0x#{@node_id.to_s(16)}"
        bytes = [0x01, 0x0A, 0x00, 0x13, @node_id, 0x03, 0x20, 0x01, val, 0x05, 0x00, 0x00]
        send_message bytes, callback_id: get_callback_id
      end
    end
  end
end
