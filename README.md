# Benchmarking Phoenix vs Rails (WIP)

Machine: MacBook Pro Intel Core i7 (2.7 GHz 4 Cores) 16 GB RAM

## Benchmarking Phoenix
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
    Latency     4.80ms    2.18ms  54.70ms   98.36%
    Req/Sec     5.61k   755.82     8.00k    71.80%
  639868 requests in 30.00s, 1.31GB read
Requests/sec:  21329.21
Transfer/sec:     44.75MB
```

## Benchmarking Rails
MRI 2.1.2

```bash
$ bundle
$ PUMA_WORKERS=3 MIN_THREADS=1 MAX_THREADS=16 RACK_ENV=production bundle exec puma
[46805] Puma starting in cluster mode...
[46805] * Version 2.8.2 (ruby 2.1.2-p95), codename: Sir Edmund Percival Hillary
[46805] * Min threads: 1, max threads: 16
[46805] * Environment: production
[46805] * Process workers: 3
[46805] * Preloading application
[46805] * Listening on tcp://0.0.0.0:3000
[46805] Use Ctrl-C to stop
[46806] + Gemfile in context: /Users/goyox86/Code/phoenix_vs_rails_showdown/rails/benchmarker/Gemfile
[46807] + Gemfile in context: /Users/goyox86/Code/phoenix_vs_rails_showdown/rails/benchmarker/Gemfile
[46808] + Gemfile in context: /Users/goyox86/Code/phoenix_vs_rails_showdown/rails/benchmarker/Gemfile
[46805] - Worker 0 (pid: 46806) booted, phase: 0
[46805] - Worker 1 (pid: 46807) booted, phase: 0
[46805] - Worker 2 (pid: 46808) booted, phase: 0

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:3000/showdown"
Running 30s test @ http://127.0.0.1:3000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    12.73ms    6.83ms  67.89ms   72.25%
    Req/Sec   418.18    250.85     0.96k    56.66%
  48544 requests in 30.00s, 108.43MB read
Requests/sec:   1618.03
Transfer/sec:      3.61MB
```


