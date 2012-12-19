module RWave
  class Message
    extend Forwardable
    def_delegator :@bytes, :length

    SOF = 0x01
    ACK = 0x06
    NAK = 0x15
    CAN = 0x18

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
        bytes[-1] = checksum
      end
      bytes.pack('C*')
    end

    # Public: Whether this message is a simple ACK or not.
    #
    # Returns boolean.
    def ack?
      bytes.first == 0x06
    end

    def to_s
      "<Message: #{unsigned_bytes.map { |b| b.to_s(16).rjust(2, '0').upcase }.join(' ')}>"
    end

    def unsigned_bytes
      bytes.map do |byte|
        byte < 0 ? 256+byte : byte
      end
    end

    def correct?
      if bytes[0] == SOF
        bytes[-1] == checksum
      else
        true
      end
    end

    private
    # The checksum is calculated for the message as follows:
    #  - remove first (SOF) and last (dummy) bytes
    #  - execute XOR each byte of the message
    #  - execute NOT on the result
    #
    # Because there is not byte type in ruby we have to make sure the
    # result is an unsigned integer.
    def checksum
      data = bytes.clone[1...-1]
      ret = ~data.inject(data.shift) { |acc, byte| acc ^ byte }
      ret < 0 ? 256+ret : ret
    end
  end
end
