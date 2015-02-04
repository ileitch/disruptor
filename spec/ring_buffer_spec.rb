require 'spec_helper'

describe Disruptor::RingBuffer do
  let(:buffer) { Disruptor::RingBuffer.new(32, Disruptor::TestWaitStrategy.new) }

  it 'raises an error when initialized with a size that is not a power of two' do
    expect { Disruptor::RingBuffer.new(31, Disruptor::TestWaitStrategy.new) }.to raise_error(Disruptor::BufferSizeError)
  end

  it 'accepts a block to preallocate the buffer' do
    event = double
    buffer = Disruptor::RingBuffer.new(6, Disruptor::TestWaitStrategy.new) { |slot| event }
    expect(buffer.get(0)).to eq(event)
  end
end

describe Disruptor::RingBuffer, 'claim' do
  let(:buffer) { Disruptor::RingBuffer.new(20, Disruptor::TestWaitStrategy.new) }

  it 'returns the next sequence' do
    expect(buffer.claim).to eq(0)
    expect(buffer.claim).to eq(1)
    expect(buffer.claim).to eq(2)
  end

  it 'returns the number of claimed slots' do
    5.times { buffer.claim }
    2.times { |i| buffer.commit(i) }
    expect(buffer.claimed_count).to eq(3)
  end
end

describe Disruptor::RingBuffer, 'commit' do
  let(:wait_strategy) { double(:wait_for => nil, :notify_blocked => nil) }
  let(:buffer) { Disruptor::RingBuffer.new(12, wait_strategy) }
  let(:cursor) { double(:set => nil, :get => Disruptor::RingBuffer::INITIAL_CURSOR_VALUE) }

  before do
    allow(Disruptor::Sequence).to receive_messages(:new => cursor)
  end

  it 'waits for the cursor to reach the previous slot' do
    allow(cursor).to receive_messages(:get => 0)
    expect(wait_strategy).to receive(:wait_for).with(cursor, 15)
    buffer.commit(16)
  end

  it 'sets the cursor to the current slot' do
    allow(cursor).to receive_messages(:get => 0)
    expect(cursor).to receive(:set).with(15, 16)
    buffer.commit(16)
  end

  it 'sets the cursor to 0 for the first commit' do
    expect(cursor).to receive(:set).with(-1, 0)
    buffer.commit(0)
  end

  it 'does not wait for the cursor for the first commit into the buffer' do
    expect(wait_strategy).not_to receive(:wait_for)
    buffer.commit(0)
  end

  it 'notifies blocked publishers' do
    expect(wait_strategy).to receive(:notify_blocked)
    buffer.commit(0)
  end
end

describe Disruptor::RingBuffer, 'get/set' do
  let(:buffer) { Disruptor::RingBuffer.new(12, Disruptor::TestWaitStrategy.new) }
  let(:event) { double }

  it 'returns the event for the given seq' do
    buffer.set(16, event)
    expect(buffer.get(16)).to eq(event)
  end
end
