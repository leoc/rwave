module RWave
  class Driver
    attr_accessor :send_queue

    ## Controller capabilities
    # Specified in FUNC_ID_ZW_GET_CONTROLLER_CAPABILITIES response
    #
    # The controller is a secondary controller
    CONTROLLER_SECONDARY = 0x01
    # The controller is not using its default Home ID
    CONTROLLER_ONOTHERNETWORK = 0x02
    # There is a SUC ID Server on the network
    CONTROLLER_SIS = 0x04
    # Controller was the primary before the SIS was added
    CONTROLLER_REALPRIMARY = 0x08
    # Controller is a static update controller
    CONTROLLER_SUC = 0x10

    def library_type_name
      case @library_type
      when 0 then "Unknown"
      when 1 then "Static Controller"
      when 2 then "Controller"
      when 3 then "Enhanced Slave"
      when 4 then "Slave"
      when 5 then "Installer"
      when 6 then "Routing Slave"
      when 7 then "Bridge Controller"
      when 8 then "Device Under Test"
      end
    end

    def initialize dev, manager
      @manager = manager
      @serial = EventMachine.open_serial(dev, 115200, 8, 1, 0)
      @serial.on_data do |data|
        receive_bytes data.unpack('C*')
      end
      @receive_buffer = []

      @send_queue = EM::Queue.new
      @callback_id_pool = 0
      @current_message = nil
      @send_queue.pop self.method(:send_message)

      initialize_sequence
    end

    def initialize_sequence
      enqueue_message(Message.new(Message::SOF, 3, Message::REQUEST, Message::Function::GET_VERSION, 0))
      enqueue_message(Message.new(Message::SOF, 3, Message::REQUEST, Message::Function::MEMORY_GET_ID, 0))
      enqueue_message(Message.new(Message::SOF, 3, Message::REQUEST, Message::Function::GET_CONTROLLER_CAPABILITIES, 0))
      enqueue_message(Message.new(Message::SOF, 3, Message::REQUEST, Message::Function::SERIAL_API_GET_CAPABILITIES, 0))
      enqueue_message(Message.new(Message::SOF, 3, Message::REQUEST, Message::Function::GET_SUC_NODE_ID, 0))
    end

    def receive_bytes bytes
      if bytes[0] == Message::ACK and bytes.length > 1
        receive_message Message.new(bytes[0])
        receive_message Message.new(*bytes[1..-1])
      else
        receive_message Message.new(*bytes)
      end
    end

    def receive_message message
      puts "#{'<< '.green.bold}#{'received'.green}: #{message}"

      # TODO: add retry if missing ack

      if message.valid?
        unless message.ack?
          send_ack

          case message[3]
          when Message::Function::GET_VERSION
            @library_version = message[4...-2].pack('C*')
            @library_type = message[-2]
            puts "Received response to GET_VERSION:"
            puts "  Library Version: #{@library_version}"
            puts "  Library Type: #{@library_type} (#{library_type_name})"
          when Message::Function::MEMORY_GET_ID
            # build an unsigned int of 32 bytes for the home id
            @home_id = (message[4] << 24) | (message[5] << 16) | (message[6] << 8) | message[7]
            @node_id = message[8]
            puts "Received response to MEMORY_GET_ID:"
            puts "  Home ID: #{@home_id.to_s(16)}"
            puts "  Node ID: #{@node_id}"
          when Message::Function::GET_CONTROLLER_CAPABILITIES
            @controller_caps = message[4]
            puts "Received reply to GET_CONTROLLER_CAPABILITIES"
            if @controller_caps & CONTROLLER_SIS != 0
              puts "  There is a SUC ID Server (SIS) in this network."
              puts "  The PC controller is an inclusion" +
                ((@controller_caps & CONTROLLER_SUC != 0) ? " static update controller (SUC)" : " controller") +
                ((@controller_caps & CONTROLLER_ONOTHERNETWORK != 0) ? " which is using a Home ID from another network" : "") +
                ((@controller_caps & CONTROLLER_REALPRIMARY != 0) ? " and was the original primary before the SIS was added." : ".")
            else
              puts "  There is no SUC ID Server (SIS) in this network."
              puts "  The PC controller is a" +
                ((@controller_caps & CONTROLLER_SECONDARY != 0) ? " secondary" : " primary") +
                ((@controller_caps & CONTROLLER_SUC != 0) ? " static update controller (SUC)" : " controller") +
                ((@controller_caps & CONTROLLER_ONOTHERNETWORK != 0) ? " which is using a Home ID from another network." : ".")
            end
          when Message::Function::SERIAL_API_GET_CAPABILITIES
            @api_version = "#{message[4]}.#{message[5]}"
            @manufacturer_id = message[6] << 8 | message[7]
            @product_type = message[8] << 8 | message[9]
            @product_id = message[10] << 8 | message[11]

            # The bytes 12 .. 43 are a 256-bit bitmask with one bit
            # set for each function id method supported by the
            # controller.
            @api_mask = message[12...-1]

            puts "Received reply to FUNC_ID_SERIAL_API_GET_CAPABILITIES"
            puts "  Serial API Version:   #{@api_version}"
            puts "  Manufacturer ID:      0x#{@manufacturer_id.to_s(16)}"
            puts "  Product Type:         0x#{@product_type.to_s(16)}"
            puts "  Product ID:           0x#{@product_id.to_s(16)}"

            if bridge_controller?
              enqueue_message(Message.new(Message::SOF, 3, Message::REQUEST, Message::Function::GET_VIRTUAL_NODES, 0))
            else
              enqueue_message(Message.new(Message::SOF, 4, Message::REQUEST, Message::Function::GET_RANDOM, 32, 0))
            end
            enqueue_message(Message.new(Message::SOF, 3, Message::REQUEST, Message::Function::SERIAL_API_GET_INIT_DATA, 0))
          when Message::Function::GET_SUC_NODE_ID
            @suc_node_id = message[4]
            puts "Received reply to GET_SUC_NODE_ID. Node ID = #{@suc_node_id.to_s(16)}"
          when Message::Function::GET_RANDOM
            puts "Received reply to GET_RANDOM: #{message[4]}"
          when Message::Function::SERIAL_API_GET_INIT_DATA
            @init_version = message[4]
            @init_caps = message[5]

            if message[6] == 29
              0.upto(29-1) do |i|
                0.upto(7) do |j|
                  node_id = (i*8)+j+1
                  if message[i+7] & (0x01 << j) != 0
                    if virtual_node?(node_id)
                      # does not matter
                    else
                      node =  Node.new(@home_id, node_id, self)
                      @nodes << node
                      node.protocol_info
                    end
                  else
                    # node does not exist anymore
                  end
                end
              end
            end
          else
            puts 'Unknown handler'
          end
          messenging_complete!
        end
      else
        puts "Checksum for message is not correct!"
        send_nak
      end
    end

    def enqueue_message message
      @send_queue.push message
    end

    def send_message message
      @current_message = message unless message.ack?
      @serial.send_data message.buf
      puts "#{'>>'.red.bold} #{'sent'.red}: #{message}"
    end

    def send_ack
      send_message(Message.ack)
    end

    def send_nak
      send_message(Message.nak)
    end

    def messenging_complete!
      puts "Messenging complete!"
      @send_queue.pop self.method(:send_message)
    end

    def get_callback_id
      @callback_id_pool += 1
      @callback_id_pool = 1 if @callback_id_pool > 255
      @callback_id_pool
    end

    def virtual_node?(node_id)
      # TODO: to be implemented by someone that has some of those devices
      false
    end

    def bridge_controller?
      @library_type == 7
    end
  end
end
