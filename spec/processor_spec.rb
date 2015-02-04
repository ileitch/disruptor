require 'spec_helper'

describe Disruptor::Processor do
  let(:processor_subclass) do
    c = Class.new
    c.send(:include, Disruptor::Processor)
    c
  end

  it 'raises a NotImplementedError if the subclass does not implement handle_event' do
    expect { processor_subclass.new.process_event(double) }.to raise_error(NotImplementedError)
  end

  it 'raises an error when a subclass overrides the setup method' do
    expect { processor_subclass.define_method(:setup) { } }.to raise_error
  end
end

describe Disruptor::Processor, 'process_next_sequence' do
  class MyProcessor
    include Disruptor::Processor
    attr_accessor :processed_event
    def process_event(e)
      self.processed_event = e
    end
  end

  let(:event) { double }
  let(:sequence) { double(:increment => 10 ) }
  let(:buffer) { double(:get => event) }
  let(:barrier) { double(:wait_for => nil, :processor_stopping => nil) }
  let(:processor) { MyProcessor.new }

  before { processor.setup(buffer, barrier, sequence) }

  it 'increments the sequence' do
    expect(sequence).to receive(:increment)
    processor.process_next_sequence
  end

  it 'waits for the next sequence' do
    expect(barrier).to receive(:wait_for).with(10)
    processor.process_next_sequence
  end

  it 'gets the event for the sequence' do
    expect(buffer).to receive(:get).with(10)
    processor.process_next_sequence
  end

  it 'dispatches the event processor' do
    expect do
      processor.process_next_sequence
    end.to change(processor, :processed_event).from(nil).to(event)
  end
end

describe Disruptor::Processor, 'stop' do
  let(:processor_subclass) do
    c = Class.new
    c.send(:include, Disruptor::Processor)
    c
  end

  let(:buffer) { double(:claim => nil, :set => nil, :commit => nil) }
  let(:thread) { double }
  let(:processor) { processor_subclass.new }
  let(:barrier) { double(:processor_stopping => nil) }

  before do
    processor.setup(buffer, barrier, nil)
    allow(Thread).to receive_messages(:new => thread)
  end

  it 'claims a slot in the buffer for the Stop instruction' do
    expect(buffer).to receive(:claim)
    processor.stop
  end

  it 'adds a Stop instruction into the buffer' do
    allow(buffer).to receive_messages(:claim => 1)
    expect(buffer).to receive(:set).with(1, Disruptor::Processor::Stop)
    processor.stop
  end

  it 'commits the Stop instruction in the buffer' do
    expect(buffer).to receive(:commit)
    processor.stop
  end

  it 'joins the thread' do
    processor.start
    expect(thread).to receive(:join)
    processor.stop
  end
end