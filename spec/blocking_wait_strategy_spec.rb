require 'spec_helper'

describe Disruptor::BlockingWaitStrategy do
  let(:mutex) { stub }
  let(:condition) { stub(:broadcast => nil) }
  let(:strategy) { Disruptor::BlockingWaitStrategy.new }
  let(:sequence) { stub }

  before do
    mutex.stub(:synchronize).and_yield
    Mutex.stub(:new => mutex)
    ConditionVariable.stub(:new => condition)
  end

  it 'returns when the sequence value reaches the given slot' do
    sequence.stub(:get => 1)
    strategy.wait_for(sequence, 1)
  end

  it 'sleeps if the sequence has not reached the given slot'

  it 'notifies all blocked publishers' do
    condition.should_receive(:broadcast)
    strategy.notify_blocked
  end
end