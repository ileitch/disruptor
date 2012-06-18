require 'spec_helper'

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
  let(:cursor) { stub(:set => nil, :get => Disruptor::RingBuffer::INITIAL_CURSOR_VALUE) }

  before do
    Disruptor::Sequence.stub(:new => cursor)
    buffer.stub(:wait_for_cursor)
  end

  it 'waits for the cursor to reach the previous slot' do
    cursor.stub(:get => 0)
    buffer.should_receive(:wait_for_cursor).with(15)
    buffer.commit(16)
  end

  it 'sets the cursor to the current slot' do
    cursor.stub(:get => 0)
    cursor.should_receive(:set).with(16)
    buffer.commit(16)
  end

  it 'sets the cursor to 0 for the first commit' do
    cursor.should_receive(:set).with(0)
    buffer.commit(0)
  end

  it 'does not wait for the cursor for the first commit into the buffer' do
    buffer.should_not_receive(:wait_for_cursor)
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