require 'spec_helper'

describe Disruptor::Queue do
  let(:queue) { Disruptor::Queue.new(12, Disruptor::BusySpinWaitStrategy.new) }

  it 'can push and pop an object' do
    t1 = Thread.new { queue.push(:data) }
    t2 = Thread.new { queue.pop }
    [t1, t2].map(&:join)
    t2.value.should == :data
  end
end