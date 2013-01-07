require 'rwave/message_function'

module RWave
  class Message
    class MissingParametersError < Exception; end

    attr_accessor :bytes

    SOF = 0x01
    ACK = 0x06
    NAK = 0x15
    CAN = 0x18

    REQUEST = 0x00
    RESPONSE = 0x01

    class << self
      def ack
        Message.new(ACK)
      end

      def nak
        Message.new(NAK)
      end

      def can
        Message.new(CAN)
      end
    end

    # Public: Create a new message object.
    def initialize(*bytes)
      @bootstrapped = false
      @bytes = bytes
    end

    def [] index
      @bytes[index]
    end

    def length
      @bytes.length
    end

    def buf
      @bytes[-1] = generate_checksum if sof?
      @bytes.pack('C*')
    end

    # Public: Whether this message is a request.
    #
    # Returns boolean.
    def request?
      @bytes[2] == Message::REQUEST
    end

    # Public: Whether this message is a response.
    #
    # Returns boolean.
    def response?
      @bytes[2] == Message::RESPONSE
    end

    # Public: Whether this message is a normal message or not.
    #
    # Returns boolean.
    def sof?
      @bytes.first == Message::SOF
    end

    # Public: Whether this message is an ACK message or not.
    #
    # Returns boolean.
    def ack?
      @bytes.first == Message::ACK
    end

    # Public: Whether this message is a NAK message or not.
    #
    # Returns boolean.
    def nak?
      @bytes.first == Message::NAK
    end

    # Public: Whether this message is a CAN message or not.
    #
    # Returns boolean.
    def can?
      @bytes.first == Message::CAN
    end

    def format_string
      case @bytes.first
      when SOF then 'SOF'
      when ACK then 'ACK'
      when NAK then 'NAK'
      when CAN then 'CAN'
      end
    end

    def to_s
      bytes = @bytes.clone
      bytes.map! { |b| b < 0 ? 256+b : b }
      bytes.map! { |b| b.to_s(16).rjust(2, '0').upcase }
      "Message: #{bytes.join(' ')} (#{format_string}" +
        (sof? ? ", #{request? ? 'REQUEST' : 'RESPONSE'}, #{Message::Function.to_s(@bytes[3])}" : '') +
        ")"
    end

    # Specifies whether this message is valid. (e.g. the last byte is
    #   a valid checksum)
    def valid?
      if sof?
        @bytes.last == generate_checksum
      else
        true
      end
    end

    # The checksum is calculated for the message as follows:
    #  - remove first (SOF) and last (dummy) bytes
    #  - execute XOR each byte of the message
    #  - execute NOT on the result
    #
    # Because there is not byte type in ruby we have to make sure the
    # result is an unsigned integer.
    def generate_checksum
      data = @bytes.clone[1...-1]
      ret = ~data.inject(data.shift) { |acc, byte| acc ^ byte }
      ret < 0 ? 256+ret : ret
    rescue
      binding.pry
    end
  end
end
