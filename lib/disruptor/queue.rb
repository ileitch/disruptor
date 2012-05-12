module Disruptor
  class Popper
    include Disruptor::Processor
  end

  class Queue
    def initialize(size)
      @buffer = RingBuffer.new(size)
      @sequence = Sequence.new
      @barrier = ProcessorBarrier.new(@buffer)
      @poppers = {}
    end

    def push(obj)
      seq = @buffer.claim
      @buffer.set(seq, obj)
      @buffer.commit(seq)
    end

    def pop
      if popper = @poppers[Thread.__id__]
        popper.next_event
      else
        popper = Disruptor::Popper.new
        popper.setup(@buffer, @barrier, @sequence)
        @poppers[Thread.__id__] = popper
        popper.next_event
      end
    end
  end
end