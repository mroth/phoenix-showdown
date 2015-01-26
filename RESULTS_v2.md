# Comparative Benchmark Numbers, Round 2
 - 4.0GHZ Core i7 (quad core), 32GB RAM
 - Applications at commit `c0da577`.

| Framework      | Throughput (req/s) | Latency (ms) | Consistency (σ ms) |
| :------------- | -----------------: | -----------: | -----------------: |
| Gin            |          51483.20  |        1.94  |              0.63  |
| Phoenix        |          43063.45  |        2.82  |        _(1)_ 7.46  |
| Express Cluster|          27669.46  |        3.73  |              2.12  |
| Martini        |          14798.46  |        6.81  |             10.34  |
| Sinatra        |           9182.86  |        6.55  |              3.03  |
| Express        |           9965.56  |       10.07  |              0.95  |
| Rails          |           3274.81  |       17.25  |              6.88  |
| Plug _(1)_     |          54948.14  |        3.83  |             12.40  |
| Play _(2)_     |          63256.20  |        1.62  |              2.96  |


 1. Consistency for both Erlang solutions have become more unstable in this
 round of tests compared to previous (where it was rock solid).  It appears to
 be somewhat specific to my Erlang install, but I haven't been able to locate a
 reason for it yet. Some others are experiencing similar results, we have been
 discussing this in the `#elixir-lang` IRC channel if you want to help.
 
 2. Play _consistently_ appeared to generate hundreds of socket read errors (see
 the detailed output), so I believe it should probably be semi-disqualified from
 the results for now.

## Detailed Results

### Benchmarking Phoenix
Elixir 1.0.2, Erlang/OTP 17.4

```bash
$ MIX_ENV=prod elixir -pa _build/prod/consolidated -S mix phoenix.server
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.82ms    7.46ms 111.90ms   99.29%
    Req/Sec    11.39k     1.38k   22.20k    79.52%
  1291740 requests in 30.00s, 2.65GB read
Requests/sec:  43063.45
Transfer/sec:     90.31MB
```

### Benchmarking Rails
MRI 2.2.0

```bash
$ PUMA_WORKERS=4 MIN_THREADS=1 MAX_THREADS=16 RACK_ENV=production bundle exec puma
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    17.25ms    6.88ms  60.73ms   70.24%
    Req/Sec   834.28    478.75     1.52k    59.37%
  98246 requests in 30.00s, 216.93MB read
Requests/sec:   3274.81
Transfer/sec:      7.23MB
```

### Benchmarking Sinatra
MRI 2.2.0

```bash
$ RACK_ENV=production bundle exec puma -t 1:16 -w 4 --preload
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     6.55ms    3.03ms  27.06ms   70.27%
    Req/Sec     2.35k   601.14     3.85k    56.21%
  275491 requests in 30.00s, 568.28MB read
Requests/sec:   9182.86
Transfer/sec:     18.94MB
```

### Benchmarking Express
NodeJS 0.10.35

#### Single process
```bash
$ NODE_ENV=production node server.js
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    10.07ms    0.95ms  22.61ms   93.58%
    Req/Sec     2.55k   186.20     3.05k    80.42%
  298966 requests in 30.00s, 624.69MB read
Requests/sec:   9965.56
Transfer/sec:     20.82MB

```
#### With clustering
```bash
$ NODE_ENV=production node server.js -w 4
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.73ms    2.12ms  27.03ms   58.27%
    Req/Sec     7.21k     1.55k   11.87k    65.77%
  830093 requests in 30.00s, 1.69GB read
Requests/sec:  27669.46
Transfer/sec:     57.82MB
```

### Benchmarking Martini
Go 1.4.1

```bash
$ GOMAXPROCS=4 MARTINI_ENV=production go run server.go
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     6.81ms   10.34ms 128.39ms   89.09%
    Req/Sec     3.75k   458.98     5.65k    68.21%
  443951 requests in 30.00s, 0.86GB read
Requests/sec:  14798.46
Transfer/sec:     29.45MB
```

### Benchmarking Gin
Go 1.4.1

```bash
$ GOMAXPROCS=4 GIN_MODE=release go run server.go
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.94ms  634.87us   9.74ms   73.07%
    Req/Sec    13.59k     1.04k   16.89k    68.29%
  1544474 requests in 30.00s, 2.98GB read
Requests/sec:  51483.20
Transfer/sec:    101.73MB
```

### Benchmarking Play
java version "1.8.0_31",
Java(TM) SE Runtime Environment (build 1.8.0_31-b13),
Java HotSpot(TM) 64-Bit Server VM (build 25.31-b07, mixed mode)

```bash
$ ./activator clean stage
$ ./target/universal/stage/bin/play-scala -Dhttp.port=5000
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.62ms    2.96ms 158.11ms   97.86%
    Req/Sec    16.23k     3.31k   24.83k    83.77%
  1897693 requests in 30.00s, 3.62GB read
  Socket errors: connect 0, read 151, write 0, timeout 0
Requests/sec:  63256.20
Transfer/sec:    123.43MB
```

### Benchmarking Plug
Elixir 1.0.2, Erlang/OTP 17.4

```bash
$ MIX_ENV=prod elixir -pa _build/prod/consolidated -S mix server
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.83ms   12.40ms  76.46ms   96.71%
    Req/Sec    14.55k     3.59k   41.22k    82.89%
  1648600 requests in 30.00s, 3.31GB read
  Socket errors: connect 0, read 2, write 0, timeout 0
Requests/sec:  54948.14
Transfer/sec:    113.13MB
```
