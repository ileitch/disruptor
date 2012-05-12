module Disruptor
  class Popper
    include Disruptor::Processor
  end

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
      if !Thread.current[:processor]
        processor = Popper.new
        processor.setup(@buffer, @barrier, @sequence)
        Thread.current[:processor] = processor
      end

      Thread.current[:processor].next_event
    end
  end
end