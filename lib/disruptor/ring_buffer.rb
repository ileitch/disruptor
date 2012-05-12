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
    INITIAL_NEXT_VALUE = 0 # TODO: Should be -1

    attr_reader :cursor, :next

    def initialize(size, &blk)
      if size % 2 == 1
        raise BufferSizeError, 'Buffer size must be a power of two.'
      end

      @size = size
      @cursor = Sequence.new(INITIAL_CURSOR_VALUE)
      @next = Sequence.new(INITIAL_NEXT_VALUE)
      @buffer = Array.new(@size, &blk)
    end

    def claim
      @next.increment
    end

    def commit(seq)
      if @cursor.get == INITIAL_CURSOR_VALUE && seq == 0
        prev_slot = INITIAL_CURSOR_VALUE
      else
        prev_slot = (seq - 1) % @size
      end

      wait_for_cursor(prev_slot)
      @cursor.set(seq % @size)
    end

    def set(seq, event)
      slot = seq % @size
      @buffer[slot] = event
    end

    def get(seq)
      slot = seq % @size
      @buffer[slot]
    end

    private

    def wait_for_cursor(slot)
      while @cursor.get != slot; end
    end
  end
end