require 'spec_helper'

describe Disruptor::BusySpinWaitStrategy do
  let(:strategy) { Disruptor::BusySpinWaitStrategy.new }
  let(:sequence) { stub }

  it 'returns when the sequence value reaches the given slot' do
    sequence.stub(:get => 1)
    strategy.wait_for(sequence, 1)
  end
end