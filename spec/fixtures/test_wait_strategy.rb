module Disruptor
  class TestWaitStrategy < WaitStrategy
    def wait_for(cursor, sequence); end
  end
end