module Disruptor
  class Queue
    def initialize(size)
      @buffer = RingBuffer.new(size)
      @sequence = Sequence.new
      @barrier = ProcessorBarrier.new(@buffer)
    end

    def push(obj)
      seq = @buffer.claim
      @buffer.set(seq, obj)
      @buffer.commit(seq)
    end

    def pop
      next_sequence = @sequence.increment
      @barrier.wait_for(next_sequence)
      @buffer.get(next_sequence)
    end
  end
end