import vibe.d;

shared static this() {
  auto settings = new HTTPServerSettings;
  settings.port = 3002;
  settings.options |= HTTPServerOption.distribute;
  settings.bindAddresses = ["::1", "127.0.0.1"];

  auto router = new URLRouter();
  router.get("/:title", &title);

  listenHTTP(settings, router);

  logInfo("Please open http://127.0.0.1:3000/ in your browser.");
}

void title(HTTPServerRequest req, HTTPServerResponse res)
{
  struct Member {
    string name;
  }

  static immutable Member[] members = [
      {name: "Chris McCord"},
      {name: "Matt Sears"},
      {name: "David Stump"},
      {name: "Ricardo Thompson"}
  ];

  res.render!("index.dt", req, members);
}
