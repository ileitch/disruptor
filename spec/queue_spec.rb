require 'spec_helper'

describe Disruptor::Queue do
  it 'returns the queue size' do
    queue = Disruptor::Queue.new(6, Disruptor::TestWaitStrategy.new)
    expect(queue.size).to eq(0)
    5.times { queue.push(nil) }
    expect(queue.size).to eq(5)
    3.times { queue.pop }
    expect(queue.size).to eq(2)
    2.times { queue.pop }
    expect(queue.size).to eq(0)
  end

  describe 'with BusySpinWaitStrategy' do
    let(:queue) { Disruptor::Queue.new(12, Disruptor::BusySpinWaitStrategy.new) }

    it 'can push and pop an object' do
      q = queue
      t1 = Thread.new { 10.times { q.push(:data) } }
      t2 = Thread.new { 10.times.map { q.pop } }
      [t1, t2].map(&:join)
      expect(t2.value).to eq([:data] * 10)
    end
  end

  describe 'with BlockingWaitStrategy' do
    let(:queue) { Disruptor::Queue.new(12, Disruptor::BlockingWaitStrategy.new) }

    it 'can push and pop an object' do
      q = queue
      t1 = Thread.new { 10.times { q.push(:data) } }
      t2 = Thread.new { 10.times.map { q.pop } }
      [t1, t2].map(&:join)
      expect(t2.value).to eq([:data] * 10)
    end
  end
end
