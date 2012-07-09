module Disruptor
  #
  # This class implements a collection of Processors that share a CAS
  # protected incremental sequence.
  #
  # Processors request slots from the buffer in a gated fashion.
  # Processors A, B, C ... will never contend for the same slot in the buffer.
  #
  class ProcessorPool
    def initialize(buffer, wait_strategy)
      @sequence = Sequence.new(Disruptor::RingBuffer::INITIAL_NEXT_VALUE)
      @buffer = buffer
      @barrier = ProcessorBarrier.new(@buffer, wait_strategy)
      @processors = []
    end

    def add(processor)
      processor.setup(@buffer, @barrier, @sequence)
      @processors << processor
      processor.start
    end

    def drain
      @processors.map(&:stop)
      @processors = []
    end
  end
end