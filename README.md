# Benchmarking Phoenix vs Rails vs Sinatra vs Express vs... (WIP)

I was curious about Chris McCord's Phoenix vs Rails article and.... MORE HERE

Like many other Elixir fanboys (and I do consider myself one!), I come from a
Ruby background.  That said, I found  Rails to be a curious choice for
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

MORE HERE...

## Frameworks Compared
Comparison of the following

 * Phoenix (Elixir) - EEx
 * Rails (Ruby) - ERB
 * Sinatra (Ruby) - ERB
 * Express (NodeJS) - EJS


## Differences from original

Document any here.


## Caveats
For the most part I tried to keep things as close as possible to the original.

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
$ npm install
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


## Conclusions
The only benchmarks that _really_ matter are the ones that apply to your own
environment and use case.  This was really just for curiosity and fun.

That said,

  - As seen in the numerous caveats, looking into tuning things like caching or
  the impact of logging strategies will have a major impact on your overall app
  performance, quite possibly more than platform.  Think about your own use case
  and pick a strategy accordingly.

  - While Elixir and Phoenix are awesome, the performance numbers of the Rails
  example are somewhat contrived and not a good comparison. The performance
  benefits of Elixir/BEAM as an environment are dramatic, but not quite as
  dramatic when compared against an appropriate Ruby framework  

  - The "just add magic!" speed of NodeJS is often overstated.  
  In this particular use case, Ruby/Sinatra performed very competitively to
  NodeJS/Express when configured similarly.

  - Finally, really, please never focus on contrived benchmarks as a way to pick
  the best environment for your project. Think about your use case, and optimize
  for that as well as developer happiness.  I've used most of these languages /
  frameworks in production, and each has cases which make it more desirable.
