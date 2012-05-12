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

    def running?
      @running
    end

    def next_event
      next_sequence = @sequence.increment
      @barrier.wait_for(next_sequence)
      @buffer.get(next_sequence)
    end

    def start
      @thread = Thread.new do
        @running = true
        while running?
          begin
            event = next_event
          rescue Stop
            break
          end
          process_event(event)
        end
      end
    end

    def stop
      @running = false
      @barrier.processor_stopping
      @thread.join if @thread
    end

    def process_event(event)
      raise NotImplementedError
    end
  end
end