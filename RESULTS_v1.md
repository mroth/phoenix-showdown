### Comparative Benchmark Numbers, Round 1
 - 3.4GHZ Core i7 (quad core), 12GB RAM
 - Applications at commit 9df8110.

|                | Throughput (req/s) | Latency (ms) | Consistency (σ ms) |
| :------------- | :----------------- | :----------- | :----------------- |
| Phoenix        |          22294.75  |        4.54  |              1.75  |
| Express Cluster|          18427.80  |        6.62  |              7.26  |
| Martini        |          13148.48  |        7.62  |              3.84  |
| Sinatra        |           6657.98  |        8.80  |              4.16  |
| Express        |           6330.13  |       15.89  |              1.70  |
| Rails          |           2275.33  |       15.78  |             12.94  |
