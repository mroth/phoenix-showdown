# Benchmarking Phoenix vs Rails vs Sinatra vs Express vs Martini...

I was curious about [Chris McCord's Phoenix vs Rails article][original] -- if
you haven't read it, go do that now first.  Go ahead, this will still be here
when you get back.  It won't make much sense unless you've read the original.

Like many other Elixir enthusiasts, I come from a Ruby background.  That said, I
found Rails to be a curious choice for comparison to Phoenix, since Rails is
really a kitchen-sink framework meant to handle everything from database
migrations to asset-pipeline compilation. Sinatra, on the other hand, is a more
modular, semi-minimal framework that is appears to be pretty close in philosophy
to what Phoenix looks like at the moment (at least to me).

While I didn't expect the performance to match Elixir/Phoenix, I was curious
what would happen if I dropped those same ERB templates in a minimal Sinatra app
instead of a Rails one.

And heck, while I was there, since Express is essentially Sinatra for Node, why
not do a quick port over there for comparison too...

...And then I realized there was a Sinatra-inspired framework for Go called
Martini, so what the heck, I went crazy and made one for that as well...

**Important note:** My benchmarking here was primarily for fun, not science. It
was mostly an interesting exercise to write the identical application in many of
the "Sinatra-like" web frameworks to see how similar they were across languages.
More on this later.

## Frameworks Compared
In the end, I had a comparison of the following:

 * Phoenix (Elixir) - EEx
 * Rails (Ruby) - ERB
 * Sinatra (Ruby) - ERB
 * Express (NodeJS) - EJS
 * Martini (Go) - `template/html`

## Compared to @chrismccord's original tests
For the most part I tried to keep things as close as possible to the original
comparison.  I used the same exact templates, splitting them up into equivalent
files.  I tried to do things the same way in every instance, rather than getting
clever and micro-optimizing for performance.

If you compare the application logic across version, you should (hopefully)
find it to be very consistent.

## Caveats
There was a few gotchas that I adjusted with the new additions to try to get
at least a closer to an "apples to apples" comparison.

### Sinatra / ERB

 * Since Phoenix didn't appear to be logging to STDOUT, Rack's default logger
   was disabled to be more comparable (netting a ~35% throughput increase right
   there).

### Express / EJS

 * NodeJS cannot run multi-threaded, so cluster mode with multiple processes is
   required to take advantage of multi-core.  I used `express-cluster` to make
   this fairly trivial to implement.  I included benchmarks with this both
   enabled and disabled.

 * Express now pushes all partial/layout handling to the template engine.  EJS
   doesn't really handle block layouts, only includes.  Therefore, the "layout"
   template needs to be split into a `_layout_header` and `_layout_footer` which
   was manually included in the index template.  This probably doesn't make a
   big difference but since it's the only template difference I figured I should
   mention it.

### Martini / Go
I'm sure some people will complain about my usage of Martini versus a more
idiomatic Go solution, however this is intended to be a comparison of _similar_
style frameworks, so it makes sense to use the one that works in the same style.

### Rails / ERB
I don't find Rails to be as apt a comparison for this use case as Sinatra,
since none of it's magic is being used in this example but it hasn't been
disabled to it creates a lot of overhead.

For that reason, I didn't do too much here. That said, there is probably a lot
that can/should be disabled in Rails that is there by default for "free" if you
wanted this to be a closer comparison.  Pull requests welcome if you care!

## Updates!  Round two of benchmarks (January 2015)

Phoenix has evolved quite a bit since the first version of this post! It's taken
on a lot of great functionality, moving it perhaps closer to being a Rails
alternative than Sinatra.  This somewhat obviates the point of these benchmarks
(which were to compare to more minimal Sinatra like frameworks), but let's
update them anyhow, and see if Phoenix can maintain its excellent performance
characteristics while taking on more

Additionally, I received PRs to add two new additional frameworks to the mix.
Gin is another Sinatra-like for Go focused on performance. The Play Framework
is a JVM platform that seems a bit more similar to Rails to me, but with the
expanded functionality Phoenix has taken on, is probably a good comparison.

And finally, since Phoenix has evolved and taken on so much functionality,
José Valim contributed an example of using Plug for an ultra minimal Elixir
based solution.

## Benchmarking
Machine: iMac Intel Core i7 (3.4 GHz 4 Cores) 12 GB RAM

All benchmarks run on a local dev machine are highly suspect.  If you want
more scientific these should really be done in a production server environment.

### Benchmarking Phoenix
Elixir 1.0.2

```bash
$ MIX_ENV=prod elixir -pa _build/prod/consolidated -S mix phoenix.server
Running Elixir.Benchmarker.Router with Cowboy on port 4000

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:4000/showdown"
Running 30s test @ http://127.0.0.1:4000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     4.54ms    1.75ms  56.55ms   90.59%
    Req/Sec     5.89k   754.52     8.67k    69.55%
  668836 requests in 30.00s, 1.37GB read
Requests/sec:  22294.75
Transfer/sec:     46.78MB
```

### Benchmarking Rails
MRI 2.2.0

```bash
$ PUMA_WORKERS=4 MIN_THREADS=1 MAX_THREADS=16 RACK_ENV=production bundle exec puma
[11332] Puma starting in cluster mode...
[11332] * Version 2.8.2 (ruby 2.1.2-p95), codename: Sir Edmund Percival Hillary
[11332] * Min threads: 1, max threads: 16
[11332] * Environment: production
[11332] * Process workers: 4
[11332] * Preloading application
[11332] * Listening on tcp://0.0.0.0:3000
[11332] Use Ctrl-C to stop
[11332] - Worker 0 (pid: 11364) booted, phase: 0
[11332] - Worker 1 (pid: 11365) booted, phase: 0
[11332] - Worker 2 (pid: 11366) booted, phase: 0
[11332] - Worker 3 (pid: 11367) booted, phase: 0

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:3000/showdown"
Running 30s test @ http://127.0.0.1:3000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    15.78ms   12.94ms  58.57ms   91.30%
    Req/Sec   627.10    514.89     1.73k    49.49%
  68263 requests in 30.00s, 152.47MB read
Requests/sec:   2275.33
Transfer/sec:      5.08MB
```

### Benchmarking Sinatra
MRI 2.2.0

```bash
$ RACK_ENV=production bundle exec puma -t 1:16 -w 4 --preload
[8955] Puma starting in cluster mode...
[8955] * Version 2.9.0 (ruby 2.1.2-p95), codename: Team High Five
[8955] * Min threads: 1, max threads: 16
[8955] * Environment: production
[8955] * Process workers: 4
[8955] * Preloading application
[8955] * Listening on tcp://0.0.0.0:9292
[8955] Use Ctrl-C to stop
[8955] - Worker 0 (pid: 8987) booted, phase: 0
[8955] - Worker 1 (pid: 8988) booted, phase: 0
[8955] - Worker 2 (pid: 8989) booted, phase: 0
[8955] - Worker 3 (pid: 8990) booted, phase: 0

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:9292/showdown"
Running 30s test @ http://127.0.0.1:9292/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     8.80ms    4.16ms  43.74ms   72.05%
    Req/Sec     1.73k     0.88k    3.30k    54.38%
  199742 requests in 30.00s, 412.03MB read
Requests/sec:   6657.98
Transfer/sec:     13.73MB
```

### Benchmarking Express
NodeJS 0.10.35

#### Single process
```bash
$ NODE_ENV=production node server.js
Starting worker on port 3000

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:3000/showdown"
Running 30s test @ http://127.0.0.1:3000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    15.89ms    1.70ms  34.55ms   90.47%
    Req/Sec     1.61k   128.74     1.87k    83.28%
  189910 requests in 30.00s, 395.01MB read
Requests/sec:   6330.13
Transfer/sec:     13.17MB
```
#### With clustering
```bash
$ NODE_ENV=production node server.js -w 4
Starting worker on port 3000
Starting worker on port 3000
Starting worker on port 3000
Starting worker on port 3000

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:3000/showdown"
Running 30s test @ http://127.0.0.1:3000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     6.62ms    7.26ms  28.27ms   71.59%
    Req/Sec     5.25k     2.27k    9.86k    57.91%
  552917 requests in 30.00s, 1.12GB read
Requests/sec:  18427.80
Transfer/sec:     38.33MB
```

### Benchmarking Martini
Go 1.4.1

```bash
$ GOMAXPROCS=4 MARTINI_ENV=production go run server.go
[martini] listening on :3000 (production)

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:3000/showdown"
Running 30s test @ http://127.0.0.1:3000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     7.62ms    3.84ms  55.34ms   82.38%
    Req/Sec     3.36k   261.43     4.59k    71.54%
  394469 requests in 30.00s, 785.12MB read
Requests/sec:  13148.48
Transfer/sec:     26.17MB
```

### Comparative Benchmark Numbers

|                | Throughput (req/s) | Latency (ms) | Consistency (σ ms) |
| :------------- | :----------------- | :----------- | :----------------- |
| Phoenix        |          22294.75  |        4.54  |              1.75  |
| Express Cluster|          18427.80  |        6.62  |              7.26  |
| Martini        |          13148.48  |        7.62  |              3.84  |
| Sinatra        |           6657.98  |        8.80  |              4.16  |
| Express        |           6330.13  |       15.89  |              1.70  |
| Rails          |           2275.33  |       15.78  |             12.94  |



## Conclusions
The only benchmarks that _really_ matter are the ones that apply to your own
environment and use case.  This was really just for curiosity and fun.

That said, some things stuck out to me:

  - As seen in the numerous caveats, looking into tuning things like caching or
  the impact of logging strategies will have a major impact on your overall app
  performance, quite possibly more than platform.  Think about your own use case
  and pick a strategy accordingly.

  - The default performance of Phoenix/Elixir is quite impressive, especially
  for such young projects. Given that Elixir is also one of the most
  conceptually enjoyable languages that I've personally coded with in years, I'm
  pretty bullish about their future.

  - Looking at the NodeJS/Express performance, it's clear that if you use NodeJS
  in production on multi-core boxes, you should probably be using cluster
  workers (but do your own research, they won't be appropriate for every
  situation.)

  - Sinatra is pretty awesome to begin with.  The similarity in writing the code
  for all these frameworks was pretty astonishing (check out how similar they
  all are!), and it shows how influential the modular approach taken by Sinatra
  has been in inspiring other frameworks. If you are a Ruby user currently using
  Rails, check out Sinatra for a more bottom-up approach and compare.

Finally, really, please never focus on contrived benchmarks as a way to pick the
best environment for your project. Think about your use case, but also optimize
for developer productivity and happiness.  I've used most of these languages /
frameworks in production, and each has cases which make it more desirable in
certain circumstances.  There is no "best" language/framework for all
situations.

## Discussion / Feedback

I've worked with all of the languages involved in production systems (with the
exception of Elixir, which I'm just getting started with). That said, I'm
nowhere near an expert in any of them -- so feedback, comments, and pull
requests are encouraged.

I'm publishing this as a GitHub repo rather than a blog post since the intended
audience is nerds.  If you want to comment, in lieu of a comment thread, just
[open a GitHub issue with the subject of your comments][gh-issues] (or participate in one on
the same topic if it already exists).

## One last thing
If you enjoyed these benchmarks / programs or found them useful, please consider
[following me on GitHub][mroth-gh] or [Twitter][mroth-tw] to see when I post new
projects. :v::man::v:


[original]: http://www.littlelines.com/blog/2014/07/08/elixir-vs-ruby-showdown-phoenix-vs-rails/
[gh-issues]: https://github.com/mroth/phoenix-showdown/issues
[mroth-gh]: https://github.com/mroth
[mroth-tw]: https://twitter.com/mroth
