module Disruptor
  #
  # This class implements a thread-safe read barrier between the buffer
  # and Processors.
  #
  # Processors ask the barrier for the next sequence they want, the barrier
  # spins waiting for the sequence to become available.
  # This is achieved without CAS as the buffer's cursor is protected by a
  # memory barrier.
  #
  #           <- claimed ->
  # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  #        ^                 ^
  #        cursor            next
  #
  # In this example sequences 0, 1 and 2 are available for reading by
  # the processors.
  #
  class ProcessorBarrier
    def initialize(buffer, wait_strategy)
      @buffer = buffer
      @wait_strategy = wait_strategy
      @last_known_sequence = Disruptor::RingBuffer::INITIAL_CURSOR_VALUE
    end

    def wait_for(sequence)
      # Optimization:
      # Store the last known cursor value in local memory to avoid
      # going down into the primitive Sequence#get.
      return if sequence < @last_known_sequence

      @wait_strategy.wait_for(@buffer.cursor, sequence)

      # TODO: Candidate for cache-line padding?
      @last_known_sequence = @buffer.cursor.get
    end
  end
end