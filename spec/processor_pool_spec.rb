require 'spec_helper'

describe Disruptor::ProcessorPool, 'add' do
  let(:buffer) { double }
  let(:pool) { Disruptor::ProcessorPool.new(buffer, Disruptor::TestWaitStrategy.new) }
  let(:barrier) { double }
  let(:sequence) { double }
  let(:processor) { double(:setup => nil, :start => nil) }

  before do
    allow(Disruptor::ProcessorBarrier).to receive_messages(:new => barrier)
    allow(Disruptor::Sequence).to receive_messages(:new => sequence)
  end

  it 'calls setup on the given processor' do
    expect(processor).to receive(:setup).with(buffer, barrier, sequence)
    pool.add(processor)
  end

  it 'starts the processor' do
    expect(processor).to receive(:start)
    pool.add(processor)
  end
end

describe Disruptor::ProcessorPool, 'drain' do
  let(:buffer) { double }
  let(:pool) { Disruptor::ProcessorPool.new(buffer, Disruptor::TestWaitStrategy.new) }
  let(:processor) { double(:setup => nil, :start => nil) }

  before { pool.add(processor) }

  it 'stops each processor' do
    expect(processor).to receive(:stop)
    pool.drain
  end
end