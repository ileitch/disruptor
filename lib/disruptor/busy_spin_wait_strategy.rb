module Disruptor
  #
  # Implements a Busy Spin wait strategy.
  #
  # Use when throughput and latency are of more concern than CPU resources.
  #
  # Typically this strategy is preferred when the number of threads is <= the
  # number of logical cores.
  #
  class BusySpinWaitStrategy < WaitStrategy
    def wait_for(cursor, sequence)
      while cursor.get < sequence; end
    end
  end
end
