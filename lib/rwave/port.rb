module RWave
  class Port
    attr_accessor :send_queue

    def initialize dev
      @serial = EventMachine.open_serial(dev, 115200, 8, 1, 0)
      @serial.on_data do |data|
        receive_bytes data.unpack('C*')
      end
      @send_queue = EM::Queue.new
      @callback_id_pool = 0
      @on_message_callbacks = []
      @sent = nil
      @send_queue.pop self.method(:send_message)
    end

    def on_message &callback
      @on_message_callbacks << callback
    end

    def get_callback_id
      @callback_id_pool += 1
      @callback_id_pool = 1 if @callback_id_pool > 255
      @callback_id_pool
    end

    def messenging_complete!
      puts "Messenging complete!"
      @send_queue.pop self.method(:send_message)
    end

    def enqueue_message message
      @send_queue.push message
    end

    def send_message message
      @sent = message unless message.ack?
      @serial.send_data message.buf
      puts "sent message: #{message.to_s}"
    end

    # Public: Is executed when the EventMachine connection receives
    #   data. It makes sure that the `#receive_message` method only
    #   gets whole frames.
    def receive_bytes bytes
      if bytes[0] == Message::ACK and bytes.length > 1
        receive_message Message.new bytes[0]
        receive_message Message.new bytes[1..-1]
      else
        receive_message Message.new(bytes)
      end
    end

    def receive_message message
      puts "received message: #{message}"

      # check checksum
      if message.correct?
        send_ack unless message.ack?
      else
        puts "Checksum for message is not correct!"
      end

      invoke_message_callbacks @sent, message
    end

    def invoke_message_callbacks sent, received
      @on_message_callbacks.each do |callback|
        callback.call(sent, received)
      end
    end

    def send_ack
      send_message Message.new([ Message::ACK ])
    end
  end
end
