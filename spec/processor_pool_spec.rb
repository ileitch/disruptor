require 'spec_helper'

describe Disruptor::ProcessorPool, 'add' do
  let(:buffer) { stub }
  let(:pool) { Disruptor::ProcessorPool.new(buffer, Disruptor::TestWaitStrategy.new) }
  let(:barrier) { stub }
  let(:sequence) { stub }
  let(:processor) { stub(:setup => nil, :start => nil) }

  before do
    Disruptor::ProcessorBarrier.stub(:new => barrier)
    Disruptor::Sequence.stub(:new => sequence)
  end

  it 'calls setup on the given processor' do
    processor.should_receive(:setup).with(buffer, barrier, sequence)
    pool.add(processor)
  end

  it 'starts the processor' do
    processor.should_receive(:start)
    pool.add(processor)
  end
end

describe Disruptor::ProcessorPool, 'drain' do
  let(:buffer) { stub }
  let(:pool) { Disruptor::ProcessorPool.new(buffer, Disruptor::TestWaitStrategy.new) }
  let(:processor) { stub(:setup => nil, :start => nil) }

  before { pool.add(processor) }

  it 'stops each processor' do
    processor.should_receive(:stop)
    pool.drain
  end
end