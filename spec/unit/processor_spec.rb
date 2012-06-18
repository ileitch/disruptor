require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Disruptor::Processor do
  let(:processor_subclass) do
    c = Class.new
    c.send(:include, Disruptor::Processor)
    c
  end

  it 'raises a NotImplementedError if the subclass does not implement handle_event' do
    expect { processor_subclass.new.process_event(stub) }.should raise_error(NotImplementedError)
  end

  it 'raises an error when a subclass overrides the setup method' do
    expect { processor_subclass.define_method(:setup) { } }.should raise_error
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

  let(:event) { stub }
  let(:sequence) { stub(:increment => 10 ) }
  let(:buffer) { stub(:get => event) }
  let(:barrier) { stub(:wait_for => nil, :processor_stopping => nil) }
  let(:processor) { MyProcessor.new }

  before { processor.setup(buffer, barrier, sequence) }

  it 'increments the sequence' do
    sequence.should_receive(:increment)
    processor.process_next_sequence
  end

  it 'waits for the next sequence' do
    barrier.should_receive(:wait_for).with(10)
    processor.process_next_sequence
  end

  it 'gets the event for the sequence' do
    buffer.should_receive(:get).with(10)
    processor.process_next_sequence
  end

  it 'disptachers the event processor' do
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

  let(:thread) { stub }
  let(:processor) { processor_subclass.new }
  let(:barrier) { stub(:processor_stopping => nil) }

  before do
    processor.setup(nil, barrier, nil)
    Thread.stub(:new => thread)
  end

  it 'notifies the barrier to abort the waiting for a sequence' do
    barrier.should_receive(:processor_stopping)
    processor.stop
  end

  it 'changes the running? status to false' do
    processor.stop
    processor.running?.should be_false
  end

  it 'joins the thread' do
    processor.start
    thread.should_receive(:join)
    processor.stop
  end
end