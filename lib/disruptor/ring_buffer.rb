module Disruptor
  #
  # This class implements an n-writer ring buffer.
  #
  # A publisher must first claim a slot in the buffer before it can write
  # any data. This is achieved using a pointer to the next available slot
  # which is incremented using CAS. Once the Publisher has written data
  # it commits it (makes it visible to Processors) by setting a cursor
  # pointer.
  #
  # Publishers commit in the same order they claim a slot, this is enforced
  # for you by the buffer. For example, Publisher A has claimed slot 1 and
  # Publisher B slot 2. Publisher A - for whatever reason - may take more
  # time to commit the slot than Publisher B. In this scenario Publisher B
  # will spin trying to set the cursor until A commits.
  #
  # Note that the actual position of data in the ring buffer is never known
  # outside of the buffer. Publishers and Processors communicate with the
  # buffer using a non-looping sequence. The buffer uses the sequence
  # modulo the buffer size as the physical slot.
  #
  class RingBuffer
    INITIAL_CURSOR_VALUE = -1
    INITIAL_NEXT_VALUE = 0

    attr_reader :cursor, :next

    def initialize(size, wait_strategy, &blk)
      if size % 2 == 1
        raise BufferSizeError, 'Buffer size must be a power of two.'
      end

      @size = size
      @wait_strategy = wait_strategy
      @cursor = Sequence.new(INITIAL_CURSOR_VALUE)
      @next = Sequence.new(INITIAL_NEXT_VALUE)
      @buffer = Array.new(@size, &blk)
    end

    def claim
      @next.increment
    end

    def commit(seq)
      if @cursor.get != INITIAL_CURSOR_VALUE && seq != INITIAL_NEXT_VALUE
        @wait_strategy.wait_for(@cursor, seq - 1)
      end

      @cursor.set(seq - 1, seq)
      @wait_strategy.notify_blocked
    end

    def set(seq, event)
      @buffer[seq % @size] = event
    end

    def get(seq)
      @buffer[seq % @size]
    end

    def claimed_count
      @next.get - @cursor.get - 1
    end
  end
end
