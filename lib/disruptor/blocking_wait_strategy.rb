module Disruptor
  #
  # Implements a lock based wait strategy.
  #
  # Use when CPU resources are more of a concern than throughput and latency.
  #
  # Blocking causes a context switch when the thread sleeps, consider the
  # BusySpinWaitStrategy instead if you expect the wait time to be less than
  # the time it takes perform a context switch.
  #
  # This strategy is preferred if you have more threads than logical cores.
  #
  class BlockingWaitStrategy < WaitStrategy
    def initialize
      @mutex = Mutex.new
      @cond = ConditionVariable.new
    end

    def wait_for(cursor, sequence)
      while cursor.get < sequence
        @mutex.synchronize { @cond.wait(@mutex) }
      end
    end

    def notify_blocked
      @mutex.synchronize { @cond.broadcast }
    end
  end
end