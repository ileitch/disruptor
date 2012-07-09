$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'disruptor'
require 'benchmark'
require 'thread'

width = 14
n = 6_000_000

Benchmark.bm(width) do |x|
  disruptor = Disruptor::Queue.new(n, Disruptor::BusySpinWaitStrategy.new)
  queue = Queue.new

  n.times do
    disruptor.push(nil)
    queue.push(nil)
  end

  x.report('disruptor:') do
    n.times { disruptor.pop }
  end

  x.report('    queue:') do
    n.times { queue.pop }
  end
end