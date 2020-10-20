require "./spec_helper"

describe AvalancheMQ::Server do
  describe "UNIX Sockets" do
    it "can accept UNIX socket connections" do
      spawn { s.listen_unix("/tmp/spec/avalanchemq.sock") }
      sleep 0.1
      with_channel(host: "/tmp/spec/avalanchemq.sock") do |ch|
        ch.should_not be_nil
      end
    end
  end
end
