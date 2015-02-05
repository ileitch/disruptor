module Disruptor
  class Sequence
    INITIAL_VALUE = 0

    def initialize(initial = INITIAL_VALUE)
      @sequence = Concurrent::Atomic.new(initial)
    end

    def get
      @sequence.get
    end

    def set(current_seq, new_seq)
      until @sequence.compare_and_set(current_seq, new_seq); end
    end

    def increment
      loop do
        current_seq = @sequence.get
        next_seq = current_seq + 1
        return current_seq if @sequence.compare_and_set(current_seq, next_seq)
      end
    end
  end
end
