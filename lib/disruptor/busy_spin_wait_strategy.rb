module Disruptor
  #
  # Implements a Busy Spin wait strategy.
  #
  # Use when CPU resources are more of a concern than throughput and latency.
  #
  # Typically this strategy is preferred when the number of threads is <= the
  # number of logical cores.
  #
  class BusySpinWaitStrategy
    def wait_for(sequence, slot)
      while sequence.get != slot; end
    end
  end
end