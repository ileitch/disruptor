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
    end

    # TODO: Any unwanted side-effects from using thread local storage?
    def processor_stopping
      @processor_stopping = true
    end

    def wait_for(sequence)
      while true
        if @processor_stopping
          @processor_stopping = false
          raise Disruptor::Processor::Stop
        end

        break if sequence <= @buffer.cursor.get
      end
    end
  end
end