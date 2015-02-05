require 'spec_helper'

describe Disruptor::BusySpinWaitStrategy do
  let(:strategy) { Disruptor::BusySpinWaitStrategy.new }
  let(:sequence) { double }

  it 'returns when the sequence value reaches the given slot' do
    allow(sequence).to receive_messages(get: 1)
    strategy.wait_for(sequence, 1)
  end
end
