require 'spec_helper'

describe Disruptor::Queue do
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
