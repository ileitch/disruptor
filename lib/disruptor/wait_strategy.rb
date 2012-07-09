module Disruptor
  class WaitStrategy
    def wait_for(sequence, slot)
      raise NotImplementedError
    end

    def notify_blocked; end
  end
end