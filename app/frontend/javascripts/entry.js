
require('expose?$!expose?jQuery!jquery');

//^^^We’re actually running the
//expose loader twice here, to add jQuery to both window.$ and window.jQuery.
//The expose loader works like this: require(expose?<libraryName>!<moduleName>),
//where <libraryName> will be window.libraryName and <moduleName> 
//is the module you’re including, in this case jquery.
// You can chain loaders by separating them with !

var App = require('./app');
var _ = require('lodash');
var React = require('react');
var WST = require('./work_shift_table.js.jsx');

console.log(WST);

var app = new App();
app.start();


_.times(5, function(i) {
  console.log(i);
  //console.log($);
});
