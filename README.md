# Benchmarking Phoenix vs Rails (WIP)

Machine: MacBook Pro Intel Core i7 (2.7 GHz 4 Cores) 16 GB RAM

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


