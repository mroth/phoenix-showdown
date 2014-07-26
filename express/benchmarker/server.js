#!/usr/bin/env node
var express = require('express');
var cluster = require('express-cluster');
var program = require('commander');

var PORT = 3000;

server = function() {
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

  console.log("Starting worker on port " + PORT);
  return app.listen(PORT);
}


program.option('-w, --workers <n>', 'Number of cluster workers', parseInt);
program.parse(process.argv);
if (program.workers == undefined) {
  server();
} else {
  cluster( server, {count: program.workers} );
}
