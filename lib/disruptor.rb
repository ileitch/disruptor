module Disruptor
  class BufferSizeError < StandardError; end
end

require 'disruptor/ring_buffer'
require 'disruptor/sequence'
require 'disruptor/processor'
require 'disruptor/processor_barrier'
require 'disruptor/processor_pool'