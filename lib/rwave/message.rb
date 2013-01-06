require 'rwave/message_function'

module RWave
  class Message
    class MissingParametersError < Exception; end

    SOF = 0x01
    ACK = 0x06
    NAK = 0x15
    CAN = 0x18

    REQUEST = 0x00
    RESPONSE = 0x01

    class << self

      def parse(bytes)
        if bytes.length > 1
          msg = Message.new(bytes.first)
          msg.data = bytes[2...-1]
          msg
        else
          Message.new(bytes.first)
        end
      end

      def sof(target_node_id, type, function,
              callback_required = false, reply_required = true,
              expected_reply = nil, expected_command_class = nil)
        Message.new(Message::SOF,
                    target_node_id: target_node_id,
                    type: type,
                    function: function,
                    reply_required: reply_required,
                    expected_reply: expected_reply,
                    expected_command_class: expected_command_class)
      end

      def ack
        Message.new(ACK)
      end

      def nak
        Message.new(NAK)
      end

      def can
        Message.new(CAN)
      end

      # The checksum is calculated for the message as follows:
      #  - remove first (SOF) and last (dummy) bytes
      #  - execute XOR each byte of the message
      #  - execute NOT on the result
      #
      # Because there is not byte type in ruby we have to make sure the
      # result is an unsigned integer.
      def checksum(bytes)
        data = bytes.clone[1..-1]
        ret = ~data.inject(data.shift) { |acc, byte| acc ^ byte }
        ret < 0 ? 256+ret : ret
      end
    end

    def initialize(start_byte, options = {})
      @start_byte = start_byte
      if start_byte == Message::SOF
        options = {
          callback_required: false,
          reply_required: true,
          expected_reply: nil,
          expected_command_class: nil
        }.merge(options)

        missing = []
        missing << :target_node_id if options[:target_node_id].nil?
        missing << :type if options[:type].nil?
        missing << :function if options[:function].nil?
        missing << :callback_required if options[:callback_required].nil?

        unless missing.empty?
          raise MissingParametersError, "Missed #{missing.join(', ')}"
        end

        @target_node_id = options[:target_node_id]
        @type = options[:type]
        @function = options[:function]
        @reply_required = options[:reply_required]
        @expected_reply = options[:expected_reply]
        @expected_command_class = options[:expected_command_class]

        @data = [ @type, @function ]
      end
    end

    def <<(byte)
      data << byte
    end

    def data
      @data ||= []
    end

    def data=(data)
      @data = data
    end

    # Public: Get the messages String representation with correct
    #   checksum.
    #
    # Returns a String representation of the messages bytes.
    def to_bytes
      buffer = [ @start_byte ]
      binding.pry
      if sof?
        buffer << data.size+(@callback ? 2 : 1)
        buffer << data
        buffer.flatten!
        buffer << @callback_id if @callback_id
        buffer << Message::checksum(buffer)
      end
      buffer
    end

    def buf
      to_bytes.pack('C*')
    end

    # Public: Whether this message is a request.
    #
    # Returns boolean.
    def request?
      @type == Message::REQUEST
    end

    # Public: Whether this message is a response.
    #
    # Returns boolean.
    def response?
      @type == Message::RESPONSE
    end

    # Public: Whether this message is a normal message or not.
    #
    # Returns boolean.
    def sof?
      @start_byte == Message::SOF
    end

    # Public: Whether this message is an ACK message or not.
    #
    # Returns boolean.
    def ack?
      @start_byte == Message::ACK
    end

    # Public: Whether this message is a NAK message or not.
    #
    # Returns boolean.
    def nak?
      @start_byte == Message::NAK
    end

    # Public: Whether this message is a CAN message or not.
    #
    # Returns boolean.
    def can?
      @start_byte == Message::CAN
    end

    def to_s
      bytes = to_bytes
      bytes.map! { |b| b < 0 ? 256+b : b }
      bytes.map! { |b| b.to_s(16).rjust(2, '0').upcase }
      "<Message: #{bytes.join(' ')}>"
    end

    def correct?
      if sof?
        bytes[-1] == Message::checksum(to_bytes[0...-1])
      else
        true
      end
    end
  end
end
