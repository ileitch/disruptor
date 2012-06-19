[![Build Status](https://secure.travis-ci.org/ileitch/disruptor.png)](http://travis-ci.org/ileitch/disruptor)

# The LMAX Disruptor in Ruby.

The reference Java implementation is more of a framework than a pattern. I have simply taken the core concepts of the Disruptor. This implementation does not support multiple claim and wait strategies (yet?).

The code may serve as a handy companion for Ruby developers digging into the [Disruptor Technical Paper](http://disruptor.googlecode.com/files/Disruptor-1.0.pdf).

What I have implemented here is somewhat analogous to a busy spin wait strategy, multi-threaded claim strategy configuration. 

There is a simple Queue implementation, if you're after a lock-free queue.

## Cache-line Padding

One neat optimization the LMAX developers have used is cache-line padding of their Sequence object. Replicating this in Ruby is a little tricky as Ruby does not support native types. The problem is made even more tricky when you take into account the different internal Object structure across Ruby implementations. Perhaps a C-ext could achieve this, VM level support would be even better. Patches welcome! ;)

## Benchmarks

I'm not going to show any results here, because they're pretty meaningless. No Ruby implementation can get close to performance of the Java implementation. If you do want to use the Disruptor pattern in JRuby, you're probably better off writing an extension for the offical Disruptor.

Saying that, there are a couple of simple Queue benchmarks in `bm`.

## TODO

* Detect buffer wrap (reach? :-p) around, have the publishers wait.
* Implement different processor wait strategies.
* Implement different publisher claim strategies.
* Implement cache-line padding (possible on MRI, Rubinius?).
