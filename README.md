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
I originally didn't find Rails to be as apt a comparison for this use case as
Sinatra, since it contains a lot of functionality not being used here that
contributes to overhead.

For that reason, I didn't do too much here. That said, there is probably a lot
that can/should be disabled in Rails that is there by default for "free" if you
wanted this to be a closer comparison.  Pull requests welcome if you care!

## Updates!  Round two of benchmarks (January 2015)

Phoenix has evolved quite a bit since the first version of this post! It's taken
on a lot of great functionality, moving it perhaps closer to being a Rails
alternative than Sinatra.  This somewhat obviates the point of these benchmarks
(which were to compare to more minimal Sinatra like frameworks), but let's
update them anyhow, and see if Phoenix can maintain its excellent performance
characteristics while taking on more.

Additionally, I received PRs to add two new additional frameworks to the mix.
Gin is another Sinatra-like for Go focused on performance. The Play Framework
is a JVM platform that seems a bit more similar to Rails to me, but with the
expanded functionality Phoenix has taken on, is probably a good comparison.

And finally, since Phoenix has evolved and taken on so much functionality,
José Valim contributed an example of using Plug for an ultra minimal Elixir
based solution.

On a side note: I never expected these tests to get so much attention, a
sincere thanks to everyone who has contributed PRs, feedback, and commentary!

## Benchmarking
I ran these on my iMac Intel Core i7 (4.0 GHz 4 Cores) 32 GB RAM.

_Note: All benchmarks run on a local dev machine are highly suspect.  If you
want more scientific results these should really be done in a production server
environment._


### Comparative Benchmark Numbers

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

You can view [the detailed results](/RESULTS_v2.md),
or see the [original round of benchmarks](/RESULTS_v1.md) to compare.

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
[open a GitHub issue with the subject of your comments][gh-issues] (or
participate in one on the same topic if it already exists).

## One last thing
If you enjoyed these benchmarks / programs or found them useful, please consider
[following me on GitHub][mroth-gh] or [Twitter][mroth-tw] to see when I post new
projects. :v::man::v:


[original]: http://www.littlelines.com/blog/2014/07/08/elixir-vs-ruby-showdown-phoenix-vs-rails/
[gh-issues]: https://github.com/mroth/phoenix-showdown/issues
[mroth-gh]: https://github.com/mroth
[mroth-tw]: https://twitter.com/mroth
