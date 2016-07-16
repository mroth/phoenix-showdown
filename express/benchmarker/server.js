#!/usr/bin/env node
var express = require('express');
var cluster = require('express-cluster');
var program = require('commander');

var PORT = process.env.PORT || 3000;

server = function(options) {
  var app = express();
  app.set('view engine', 'ejs');

  app.get('/:title', function(req,res) {
    var members = [
      {name: "Chris McCord"},
      {name: "Matt Sears"},
      {name: "David Stump"},
      {name: "Ricardo Thompson"}
    ];

    res.render('index', {title: req.params.title, members: members});
  });

  console.log("Starting worker on port " + options.port);
  return app.listen(options.port);
}


program.option('-w, --workers <n>', 'Number of cluster workers', parseInt);
program.option('-p, --port <n>', 'Port number', parseInt);
program.parse(process.argv);
if (program.workers == undefined) {
  server({port: program.port});
} else {
  cluster( server.bind(null, {port: program.port}), {count: program.workers} );
}
