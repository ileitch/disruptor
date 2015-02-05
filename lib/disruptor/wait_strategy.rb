module Disruptor
  class WaitStrategy
    def wait_for(sequence, slot) # rubocop:disable Lint/UnusedMethodArgument
      raise NotImplementedError
    end

    def notify_blocked; end
  end
end
