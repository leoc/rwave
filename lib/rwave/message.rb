module RWave
  class Message
    extend Forwardable
    def_delegator :@bytes, :length

    ACK = [ 0x06 ]

    attr_accessor :callback_id, :bytes

    def initialize bytes, options = {}
      options = {
        callback_id: 0
      }.merge(options)

      @bytes = bytes
      @callback_id = options[:callback_id]
    end

    # Public: Get the messages String representation with correct
    #   checksum.
    #
    # Returns a String representation of the messages bytes.
    def buf
      unless ack?
        bytes[bytes.length-2] = @callback_id if @callback_id
        bytes[-1] = generate_checksum(bytes)
      end
      bytes.pack('C*')
    end

    # Public: Whether this message is a simple ACK or not.
    #
    # Returns boolean.
    def ack?
      bytes == Message::ACK
    end

    def to_s
      "<Message: #{bytes.inspect}>"
    end

    private
    def generate_checksum data
      bytes = data.clone
      bytes = bytes[1...-1] # remove initial byte and checksum dummy
      # fill ret with the first element to have something we can XOR with
      ret = bytes.shift
      bytes.each do |byte|
        ret ^= byte
      end
      ~ret
    end
  end
end
