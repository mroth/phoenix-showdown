# Comparative Benchmark Numbers, Round 3
 - 4.0GHZ Core i7 (quad core), 32GB RAM
 - Applications at commit `3e7a237`.

| Framework      | Throughput (req/s) | Latency (ms) | Consistency (σ ms) |
| :------------- | -----------------: | -----------: | -----------------: |
| Gin            |          59001.07  |        1.84  |              1.35  |
| Phoenix        |          31417.81  |        3.52  |              3.50  |
| Express Cluster|          26244.35  |        3.92  |              3.25  |
| Martini        |          12493.48  |       10.15  |             10.70  |
| Sinatra        |           8334.84  |        7.46  |              3.38  |
| Express        |           9477.14  |       10.56  |              1.39  |
| Rails          |           3452.58  |       17.96  |              7.73  |
| Plug           |          53815.76  |        2.67  |              4.07  |
| Play           |          66405.81  |        2.72  |             10.25  |


## Detailed Results

### Benchmarking Phoenix
Elixir 1.3.2, Erlang/OTP 19.0.2

```bash
$ MIX_ENV=prod elixir -pa _build/prod/consolidated -S mix phoenix.server
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.52ms    3.50ms  64.46ms   90.41%
    Req/Sec     7.89k   841.86    12.17k    77.00%
  943658 requests in 30.04s, 2.11GB read
Requests/sec:  31417.81
Transfer/sec:     71.98MB
```

### Benchmarking Rails
MRI 2.3.1

```bash
$ PUMA_WORKERS=4 MIN_THREADS=1 MAX_THREADS=16 RACK_ENV=production bundle exec puma
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    17.96ms    7.73ms  99.56ms   70.88%
    Req/Sec     0.87k   292.64     1.49k    52.08%
  103623 requests in 30.01s, 229.01MB read
Requests/sec:   3452.58
Transfer/sec:      7.63MB
```

### Benchmarking Sinatra
MRI 2.3.1

```bash
$ RACK_ENV=production bundle exec puma -t 1:16 -w 4 --preload
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     7.46ms    3.38ms  78.81ms   73.46%
    Req/Sec     2.09k   712.45     3.42k    55.58%
  250113 requests in 30.01s, 515.93MB read
Requests/sec:   8334.84
Transfer/sec:     17.19MB
```

### Benchmarking Express
NodeJS 6.3.0

#### Single process
```bash
$ NODE_ENV=production node server.js
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    10.56ms    1.39ms  64.42ms   95.96%
    Req/Sec     2.38k   169.54     4.55k    96.26%
  285292 requests in 30.10s, 596.66MB read
Requests/sec:   9477.14
Transfer/sec:     19.82MB
```

#### With clustering
```bash
$ NODE_ENV=production node server.js -w 4
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.92ms    3.25ms 154.38ms   99.59%
    Req/Sec     6.61k   743.14    27.02k    97.34%
  790018 requests in 30.10s, 1.61GB read
Requests/sec:  26244.35
Transfer/sec:     54.89MB
```

### Benchmarking Martini
Go 1.6.3

```bash
$ GOMAXPROCS=4 MARTINI_ENV=production go run server.go
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    10.15ms   10.70ms 157.74ms   85.94%
    Req/Sec     3.14k   472.77     4.24k    66.42%
  375032 requests in 30.02s, 746.43MB read
Requests/sec:  12493.48
Transfer/sec:     24.87MB
```

### Benchmarking Gin
Go 1.6.3

```bash
$ GOMAXPROCS=4 GIN_MODE=release go run server.go
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.84ms    1.35ms  27.78ms   81.35%
    Req/Sec    14.85k     1.97k   31.28k    90.85%
  1775977 requests in 30.10s, 3.43GB read
Requests/sec:  59001.07
Transfer/sec:    116.59MB
```

### Benchmarking Play
java version "1.8.0_51"
Java(TM) SE Runtime Environment (build 1.8.0_51-b16)
Java HotSpot(TM) 64-Bit Server VM (build 25.51-b03, mixed mode)

```bash
$ ./activator clean stage
$ ./target/universal/stage/bin/play-scala -Dhttp.port=5000
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.72ms   10.25ms 201.95ms   98.01%
    Req/Sec    16.74k     4.16k   27.83k    84.28%
  1992763 requests in 30.01s, 3.87GB read
Requests/sec:  66405.81
Transfer/sec:    132.17MB
```

### Benchmarking Plug
Elixir 1.3.2, Erlang/OTP 19.0.2

```bash
$ MIX_ENV=prod elixir -pa _build/prod/consolidated -S mix server
$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:5000/showdown"
Running 30s test @ http://127.0.0.1:5000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.67ms    4.07ms  86.50ms   91.59%
    Req/Sec    13.52k     1.85k   19.75k    72.25%
  1614839 requests in 30.01s, 3.21GB read
Requests/sec:  53815.76
Transfer/sec:    109.58MB
```
