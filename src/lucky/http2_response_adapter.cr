# HTTP2 Response Adapter for Lucky applications
#
# This adapter bridges Lucky's HTTP::Server::Response interface with HT2::Response
{% if flag?(:http2) %}
  require "ht2"

  class Lucky::HTTP2ResponseAdapter < HTTP::Server::Response
    def initialize(@ht2_response : HT2::Response)
      @output = IO::Memory.new
      super(@output)
    end

    def write(slice : Bytes) : Nil
      return if closed?
      output.write(slice)
    end

    def flush : Nil
      return if closed?
      sync_headers_to_ht2
      if @output.is_a?(IO::Memory)
        @ht2_response.write(@output.as(IO::Memory).to_slice)
      end
    end

    def close : Nil
      return if closed?
      flush
      @ht2_response.close
      super
    end

    def upgrade(&block : IO ->)
      raise "HTTP/2 does not support connection upgrades"
    end

    private def sync_headers_to_ht2
      @ht2_response.status = status_code
      headers.each do |name, values|
        values.each do |value|
          @ht2_response.headers[name.downcase] = value
        end
      end
    end
  end
{% end %}
