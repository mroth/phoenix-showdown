# Comparative Benchmark Numbers, Round 1
 - 3.4GHZ Core i7 (quad core), 12GB RAM
 - Applications at commit `9df8110`.

| Framework      | Throughput (req/s) | Latency (ms) | Consistency (σ ms) |
| :------------- | -----------------: | -----------: | -----------------: |
| Phoenix        |          22294.75  |        4.54  |              1.75  |
| Express Cluster|          18427.80  |        6.62  |              7.26  |
| Martini        |          13148.48  |        7.62  |              3.84  |
| Sinatra        |           6657.98  |        8.80  |              4.16  |
| Express        |           6330.13  |       15.89  |              1.70  |
| Rails          |           2275.33  |       15.78  |             12.94  |

## Detailed Results

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
