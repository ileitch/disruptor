require File.dirname(__FILE__) + '/../spec_helper'

describe Disruptor::RingBuffer do
  let(:buffer) { Disruptor::RingBuffer.new(32) }

  it 'raises an error when initialized with a size that is not a power of two' do
    expect { Disruptor::RingBuffer.new(31) }.should raise_error(Disruptor::BufferSizeError)
  end

  it 'accepts a block to preallocate the buffer' do
    event = stub
    buffer = Disruptor::RingBuffer.new(6) { |slot| event }
    buffer.get(0).should == event
  end
end

describe Disruptor::RingBuffer, 'claim' do
  let(:buffer) { Disruptor::RingBuffer.new(2) }
  let(:sequence) { stub(:increment => 6) }

  before { Disruptor::Sequence.stub(:new => sequence) }

  it 'increments the next pointer' do
    sequence.should_receive(:increment)
    buffer.claim
  end

  it 'returns the next sequence' do
    buffer.claim.should == 6
  end
end

describe Disruptor::RingBuffer, 'commit' do
  let(:buffer) { Disruptor::RingBuffer.new(12) }
  let(:cursor) { stub(:set => nil, :get => 0) }

  before do
    Disruptor::Sequence.stub(:new => cursor)
    buffer.stub(:wait_for_cursor)
  end

  it 'waits for the cursor to reach the previous slot' do
    buffer.should_receive(:wait_for_cursor).with(3)
    buffer.commit(16)
  end

  it 'sets the cursor to the current slot' do
    cursor.should_receive(:set).with(4)
    buffer.commit(16)
  end

  it 'sets the cursor to 0 if this is the first commit' do
    cursor.stub(:get => Disruptor::RingBuffer::INITIAL_CURSOR_VALUE)
    cursor.should_receive(:set).with(0)
    buffer.commit(0)
  end
end

describe Disruptor::RingBuffer, 'get/set' do
  let(:buffer) { Disruptor::RingBuffer.new(12) }
  let(:event) { stub }

  it 'returns the event for the given seq' do
    buffer.set(16, event)
    buffer.get(16).should == event
  end
end