# Benchmarking Phoenix vs Rails vs Sinatra vs Express vs Martini...

I was curious about [Chris McCord's Phoenix vs Rails article][original] -- if
you haven't read it, go do that now first.  Go ahead, this will still be here
when you get back.  It won't make much sense unless you've read the original.

Like many other Elixir fanboys (and I do consider myself one!), I come from a
Ruby background.  That said, I found Rails to be a curious choice for
comparison to Phoenix, since Rails is really a kitchen-sink framework meant to
handle everything from database migrations to asset-pipeline compilation.
Sinatra, on the other hand, is a more modular, semi-minimal framework that is
appears to be pretty close in philosophy to what Phoenix looks like at the
moment (at least to me).

While I didn't expect the performance to match Elixir/Phoenix, I was curious
what would happen if I dropped those same ERB templates in a minimal Sinatra app
instead of a Rails one.  And heck, while I was there, since Express is
essentially Sinatra for Node, why not do a quick port over there for comparison
too.

...And then I realized there was a Sinatra-inspired framework for Go called
Martini, so what the heck, I went crazy and made one for that as well...

## Frameworks Compared
In the end, I had a comparison of the following:

 * Phoenix (Elixir) - EEx
 * Rails (Ruby) - ERB
 * Sinatra (Ruby) - ERB
 * Express (NodeJS) - EJS
 * Martini (Go) - `template/html`

## Compared to original tests
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

 * NodeJS cannot run multi-threads, so cluster mode with multiple processes is
   required to take advantage of multi-core.  I used `express-cluster` to make
   this fairly trivial to implement.  I included benchmarks with this both
   enabled and disabled.

 * Express now pushes all partial/layout handling to the template engine.  EJS
   doesn't really handle block layouts, only includes.  Therefore, the "layout"
   template needs to be split into a `_layout_header` and `_layout_footer` which
   was manually included in the index template.  This probably doesn't make a
   big difference but since it's the only template difference I figured I should
   mention it.

 * Express uses "view template compilation caching" in production by default.  I
   disabled this for the benchmarks, since it pretty much defeats the purpose of
   this comparison which attempts to look at dynamically rendered page
   performance. (If you enable it you obviously get insane performance, which you
   should expect with if you use caching in _any framework_ in an environment
   where your requests are entirely homogenous).

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


## Benchmarking
Machine: iMac Intel Core i7 (3.4 GHz 4 Cores) 12 GB RAM

All benchmarks run on a local dev machine are highly suspect.  If you want
more scientific these should really be done in a production server environment.

### Benchmarking Phoenix
Elixir 0.14.2

```bash
$ mix do deps.get, compile
$ MIX_ENV=prod mix compile.protocols
$ MIX_ENV=prod elixir -pa _build/prod/consolidated -S mix phoenix.start
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
MRI 2.1.2

```bash
$ bundle
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
MRI 2.1.2

```bash
$ bundle
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
NodeJS 0.10.29

#### Single process
```bash
$ npm install
$ node server.js
Starting worker on port 3000

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:3000/showdown"
Running 30s test @ http://127.0.0.1:3000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    51.58ms    2.32ms  63.94ms   90.52%
    Req/Sec   486.46     25.19   547.00     67.11%
  58030 requests in 30.00s, 120.70MB read
Requests/sec:   1934.20
Transfer/sec:      4.02MB
```
#### With clustering
```bash
$ node server.js -w 4
Starting worker on port 3000
Starting worker on port 3000
Starting worker on port 3000
Starting worker on port 3000

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:3000/showdown"
Running 30s test @ http://127.0.0.1:3000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    15.86ms    9.41ms  53.07ms   63.50%
    Req/Sec     1.61k   248.42     2.18k    59.38%
  188532 requests in 30.00s, 392.14MB read
Requests/sec:   6284.41
Transfer/sec:     13.07MB
```

### Benchmarking Martini
Go 1.3

```bash
$ go get github.com/go-martini/martini
$ go get github.com/martini-contrib/render
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
| Martini        |          13148.48  |        7.62  |              3.84  |
| Sinatra        |           6657.98  |        8.80  |              4.16  |
| Rails          |           2275.33  |       15.78  |             12.94  |
| Express Cluster|           6284.41  |       15.86  |              9.41  |
| Express        |           1934.20  |       51.58  |              2.32  |

![chart-throughput][chart-throughput]
![chart-latency][chart-latency]
![chart-consistency][chart-consistency]

## Conclusions
The only benchmarks that _really_ matter are the ones that apply to your own
environment and use case.  This was really just for curiosity and fun.

That said, some things stuck out to me:

  - As seen in the numerous caveats, looking into tuning things like caching or
  the impact of logging strategies will have a major impact on your overall app
  performance, quite possibly more than platform.  Think about your own use case
  and pick a strategy accordingly.

  - That said, the default performance of Phoenix/Elixir is quite impressive,
  especially for such young projects (neither is even at a `1.0` release yet).
  Given that Elixir is also one of the most conceptually enjoyable languages
  that I've personally coded with in years, I'm pretty bullish about the future.

  - Don't write off Ruby entirely.  The original benchmark Rails example was
  not a good comparison. The performance benefits of Elixir/BEAM as an
  environment are dramatic, but not quite as dramatic when compared against an
  appropriately comparable Ruby framework such as Sinatra.

  - The "just add magic!" conception of NodeJS speed seems to be quite
  overstated. In this particular use case, Ruby/Sinatra performed very
  competitively to NodeJS/Express when configured similarly.

  - Speaking of NodeJS, the single-process version of the Express app was the
  clear worst performer (it was actually very consistent, but that consistency
  was in higher latency). I suspect what this highlights is not any deficiency
  in the framework itself, but merely a single CPU core not being able to keep
  up with the same load as 4 CPU cores (fancy that!). If you use NodeJS in
  production on multi-core boxes, you should probably be using cluster workers.

Finally, really, please never focus on contrived benchmarks as a way to pick the
best environment for your project. Think about your use case, but also optimize
for developer productivity and happiness.  I've used most of these languages /
frameworks in production, and each has cases which make it more desirable in
certain circumstances.  There is no "best" language/framework for all
situations.

## Discussion / Feedback

I've worked with all of the languages involved in production systems (with the
exception of Elixir, which I'm just [enthusiastically] getting started with).
That said, I'm nowhere near an expert in any of them -- so feedback, comments,
and pull requests are encouraged.

I'm publishing this as a GitHub repo rather than a blog post since the intended
audience is nerds.  If you want to comment, in lieu of a comment thread, just
open a GitHub issue with the subject of your comments (or participate in one on
the same topic if it already exists).

## One last thing
If you enjoyed these benchmarks / programs or found them useful, please consider
[following me on GitHub][mroth-gh] or [Twitter][mroth-tw] to see when I post new
projects.


[original]: http://www.littlelines.com/blog/2014/07/08/elixir-vs-ruby-showdown-phoenix-vs-rails/

[chart-throughput]: http://f.cl.ly/items/2s3c093X2W1f1E1B2R3j/showdown-throughput.png
[chart-latency]: http://f.cl.ly/items/3u0f340t0F3d1S1U0f19/showdown-latency.png
[chart-consistency]: http://f.cl.ly/items/2V0Z3R414133303t2z1Z/showdown-consistency.png

[mroth-gh]: https://github.com/mroth
[mroth-tw]: https://twitter.com/mroth
