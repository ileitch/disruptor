module Disruptor
  #
  # This class implements a thread-safe read barrier between the buffer
  # and Processors.
  #
  # Processors ask the barrier for the next sequence they want, the barrier
  # spins waiting for the sequence to become available.
  # This is achieved without CAS as the buffer's cursor is protected by a
  # read memory barrier.
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
    def initialize(buffer)
      @buffer = buffer
      @last_known_cursor = Disruptor::RingBuffer::INITIAL_CURSOR_VALUE
    end

    def processor_stopping
      @processor_stopping = true
    end

    def wait_for(sequence)
      # Avoid hitting the Sequence#get memory barrier if we already know the cursor
      # is ahead of the requested sequence. 
      return if sequence <= @last_known_cursor

      while true
        if @processor_stopping
          @processor_stopping = false
          raise Disruptor::Processor::Stop
        end

        if sequence <= @buffer.cursor.get
          @last_known_cursor = @buffer.cursor.get
          break
        end
      end
    end
  end
end