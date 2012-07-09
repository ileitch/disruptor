module Disruptor
  class TestWaitStrategy < WaitStrategy
    def wait_for(sequence, slot); end
  end
end