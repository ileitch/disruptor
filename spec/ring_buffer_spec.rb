require 'spec_helper'

describe Disruptor::RingBuffer do
  let(:buffer) { Disruptor::RingBuffer.new(32, Disruptor::TestWaitStrategy.new) }

  it 'raises an error when initialized with a size that is not a power of two' do
    expect { Disruptor::RingBuffer.new(31, Disruptor::TestWaitStrategy.new) }.should raise_error(Disruptor::BufferSizeError)
  end

  it 'accepts a block to preallocate the buffer' do
    event = stub
    buffer = Disruptor::RingBuffer.new(6, Disruptor::TestWaitStrategy.new) { |slot| event }
    buffer.get(0).should == event
  end
end

describe Disruptor::RingBuffer, 'claim' do
  let(:buffer) { Disruptor::RingBuffer.new(20, Disruptor::TestWaitStrategy.new) }

  it 'returns the next sequence' do
    buffer.claim.should == 0
    buffer.claim.should == 1
    buffer.claim.should == 2
  end

  it 'returns the number of claimed slots' do
    5.times { buffer.claim }
    2.times { |i| buffer.commit(i) }
    buffer.claimed_count.should == 3
  end
end

describe Disruptor::RingBuffer, 'commit' do
  let(:wait_strategy) { stub(:wait_for => nil, :notify_blocked => nil) }
  let(:buffer) { Disruptor::RingBuffer.new(12, wait_strategy) }
  let(:cursor) { stub(:set => nil, :get => Disruptor::RingBuffer::INITIAL_CURSOR_VALUE) }

  before do
    Disruptor::Sequence.stub(:new => cursor)
  end

  it 'waits for the cursor to reach the previous slot' do
    cursor.stub(:get => 0)
    wait_strategy.should_receive(:wait_for).with(cursor, 15)
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
    wait_strategy.should_not_receive(:wait_for)
    buffer.commit(0)
  end

  it 'notifies blocked publishers' do
    wait_strategy.should_receive(:notify_blocked)
    buffer.commit(0)
  end
end

describe Disruptor::RingBuffer, 'get/set' do
  let(:buffer) { Disruptor::RingBuffer.new(12, Disruptor::TestWaitStrategy.new) }
  let(:event) { stub }

  it 'returns the event for the given seq' do
    buffer.set(16, event)
    buffer.get(16).should == event
  end
end