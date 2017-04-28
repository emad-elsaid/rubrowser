# Rubrowser

[![Gem Version](https://badge.fury.io/rb/rubrowser.svg)](https://badge.fury.io/rb/rubrowser)

a visualizer for ruby code (rails or otherwise), it analyze your code and extract the modules definitions and used classes/modules and render all these information as a directed force graph using D3.

this project is so small that the visualization looks like so

![rubrowser visualization](http://i.imgur.com/5mbshee.png)

the idea is that the project opens every `.rb` file and parse it with `parser` gem then list all modules and classes definitions, and all constants that are listed inside this module/class and link them together.

Here are some output examples

| Gem        | Visualization    |
| ------------- |:-------------:|
| rack-1.6.4/lib      | ![rake](http://i.imgur.com/4UsCo0a.png) |
| actioncable-5.0.0/lib      | ![acioncable](http://i.imgur.com/Q0Xqjsz.png) |
| railties-5.0.0/lib      | ![railties](http://i.imgur.com/31g10a1.png) |

there are couple things you need to keep in mind:

* if your file doesn't have a valid ruby syntax it won't be parsed and will print warning.
* if you reference a class that is not defined in your project it won't be in the graph, we only display the graph of classes/modules you defined
* it statically analyze the code so meta programming is out of question in here
* rails associations are meta programming so forget it :smile:

## Installation


```
gem install rubrowser
```

## Usage


```
Usage: rubrowser [options] [file] ...
    -p, --port=PORT                  Specify port number for server, default = 9000
    -v, --version                    Print Rubrowser version
    -h, --help                       Prints this help
```

if you run it without any options
```
rubrowser
```
it'll analyze the current directory and open port 9000, so you can access the graph from `localhost:9000`

## Features

* interactive graph, you can pull any node to fix it to some position
* to release node double click on it
* zoom and pan with mouse or touch pad
* highlight node and all related nodes, it'll make it easier for you to see what depends and dependencies of certain class
* ignore node by name
* ignore nodes of certain type (modules/classes)
* hide namespaces
* hide relations
* change graph appearance (collision radius)
* stop animation immediately
* Module/class circle size on the graph will be relative to module number of lines in your code

## Why?

Because i didn't find a good visualization tool to make me understand ruby projects when I join a new one.

it's great when you want to get into an open source project and visualize the structure to know where to work and the relations between modules/classes.
