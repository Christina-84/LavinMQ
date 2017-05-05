module AMQPServer
  class Queue
    class QueueFile < File
      include AMQP::IO
    end

    def initialize(@name : String)
      @consumers = Array(Message -> Void).new
      @wfile = QueueFile.open("/tmp/#{@name}.q", "a")
      @rfile = QueueFile.open("/tmp/#{@name}.q", "r")
    end

    def write_msg(msg : Message)
      puts "consumers: #{@consumers.size}"
      @consumers.each { |blk| puts "calling conume block"; blk.call(msg) }
      @wfile.write_short_string msg.exchange_name
      @wfile.write_short_string msg.routing_key
      @wfile.write_int msg.size
      msg.properties.encode @wfile
      @wfile.write msg.body.to_slice
      @wfile.flush #if msg.properties.delivery_mode.try { |v| v > 0 }
    end

    def get
      return nil if @rfile.pos == @rfile.size
      ex = @rfile.read_short_string
      rk = @rfile.read_short_string
      sz = @rfile.read_uint64
      pr = AMQP::Properties.decode @rfile
      msg = Message.new(ex, rk, sz, pr)
      bytes = Bytes.new(sz)
      @rfile.read(bytes)
      msg.add_content bytes
      msg
    end

    def add_consumer(&blk : Message -> _)
      @consumers.push blk
      puts "consumers: #{@consumers.size}"
    end
  end
end
