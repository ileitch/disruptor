module Disruptor
  #
  # A simple n-reader, n-writer queue.
  #
  class Queue
    def initialize(size, wait_strategy)
      @buffer = RingBuffer.new(size, wait_strategy)
      @sequence = Sequence.new
      @barrier = ProcessorBarrier.new(@buffer, wait_strategy)
    end

    def push(obj)
      seq = @buffer.claim
      @buffer.set(seq, obj)
      @buffer.commit(seq)
      nil
    end
    alias_method :<<, :push

    def pop
      next_sequence = @sequence.increment
      @barrier.wait_for(next_sequence)
      @buffer.get(next_sequence)
    end

    def size
      @buffer.committed_count - @sequence.get
    end
  end
end
