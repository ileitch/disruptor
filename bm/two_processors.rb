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
    queue.push(nil)
    disruptor.push(nil)
  end

  x.report('disruptor:') do
    threads = []
    threads << Thread.new { (n / 2).times { disruptor.pop } }
    threads << Thread.new { (n / 2).times { disruptor.pop } }
    threads.map(&:join)
  end

  x.report('    queue:') do
    threads = []
    threads << Thread.new { (n / 2).times { queue.pop } }
    threads << Thread.new { (n / 2).times { queue.pop } }
    threads.map(&:join)
  end
end