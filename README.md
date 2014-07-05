# Benchmarking Phoenix vs Rails (WIP)


## Benchmarking Phoenix

```bash
$ mix do deps.get, compile
$ MIX_ENV=prod mix compile.protocols
$ MIX_ENV=prod elixir -pa _build/prod/consolidated -S mix phoenix.start
Running Elixir.Benchmarker.Router with Cowboy on port 4000

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:4000/showdown"
Running 10s test @ http://127.0.0.1:4000/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     8.31ms    3.53ms  43.30ms   79.38%
    Req/Sec     3.11k   376.89     4.73k    79.83%
  121202 requests in 10.00s, 254.29MB read
Requests/sec:  12120.94
Transfer/sec:     25.43MB
```

## Benchmarking Rails

```bash
$ bundle
$ RACK_ENV=production bundle exec puma -w 4
[13185] Puma starting in cluster mode...
[13185] * Version 2.8.2 (ruby 2.1.0-p0), codename: Sir Edmund Percival Hillary
[13185] * Min threads: 0, max threads: 16
[13185] * Environment: production
[13185] * Process workers: 4
[13185] * Phased restart available
[13185] * Listening on tcp://0.0.0.0:9292

$ wrk -t4 -c100 -d30S --timeout 2000 "http://127.0.0.1:9292/showdown"
Running 10s test @ http://127.0.0.1:9292/showdown
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    21.67ms   18.96ms 159.43ms   85.53%
    Req/Sec   449.74    413.36     1.10k    63.82%
  11414 requests in 10.01s, 25.50MB read
Requests/sec:   1140.53
Transfer/sec:      2.55MB
```


