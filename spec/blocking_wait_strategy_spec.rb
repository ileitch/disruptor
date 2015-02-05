require 'spec_helper'

describe Disruptor::BlockingWaitStrategy do
  let(:mutex) { double }
  let(:condition) { double(broadcast: nil) }
  let(:strategy) { Disruptor::BlockingWaitStrategy.new }
  let(:sequence) { double }

  before do
    allow(mutex).to receive(:synchronize).and_yield
    allow(Mutex).to receive_messages(new: mutex)
    allow(ConditionVariable).to receive_messages(new: condition)
  end

  it 'returns when the sequence value reaches the given slot' do
    allow(sequence).to receive_messages(get: 1)
    strategy.wait_for(sequence, 1)
  end

  it 'sleeps if the sequence has not reached the given slot'

  it 'notifies all blocked publishers' do
    expect(condition).to receive(:broadcast)
    strategy.notify_blocked
  end
end
