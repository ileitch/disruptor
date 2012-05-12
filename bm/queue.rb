$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'disruptor'
require 'benchmark'
require 'thread'

width = 20
n = 500000

Benchmark.bm(width) do |x|
  disruptor = Disruptor::Queue.new(n)
  queue = Queue.new

  x.report('disruptor push:') do
    n.times { disruptor.push(nil) }
  end

  x.report('   stdlib push:') do
    n.times { queue.push(nil) }
  end
end

Benchmark.bm(width) do |x|
  disruptor = Disruptor::Queue.new(n)
  queue = Queue.new

  n.times { disruptor.push(nil); queue.push(nil) }

  x.report('disruptor pop:') do
    n.times { disruptor.pop }
  end

  x.report('   stdlib pop:') do
    n.times { queue.pop }
  end
end