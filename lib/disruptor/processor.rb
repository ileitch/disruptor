module Disruptor
  #
  # Include this class into your event processors.
  # Your processor must implement process_event(event).
  #
  module Processor
    class Stop < StandardError; end

    def self.method_added(name)
      if name.to_sym == :setup && self != Disruptor::Processor
        raise 'Do not override setup in your processor subclass.'
      end
    end

    def setup(buffer, barrier, sequence)
      @buffer = buffer
      @barrier = barrier
      @sequence = sequence
    end

    def start
      @thread = Thread.new do
        loop do
          begin
            process_next_sequence
          rescue Stop
            break
          end
        end
      end
    end

    def process_next_sequence
      next_sequence = @sequence.increment
      @barrier.wait_for(next_sequence)
      event = @buffer.get(next_sequence)
      raise event if event == Stop
      process_event(event)
    end

    def stop
      seq = @buffer.claim
      @buffer.set(seq, Stop)
      @buffer.commit(seq)

      @thread.join if @thread
    end

    def process_event(event)
      raise NotImplementedError
    end
  end
end