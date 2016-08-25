# Rubrowser

[![Gem Version](https://badge.fury.io/rb/rubrowser.svg)](https://badge.fury.io/rb/rubrowser)

a visualizer for ruby code (rails or otherwise), it analyze your code and extract the modules definitions and used classes/modules and render all these information as a directed force graph using D3.

this project is so small that the visualization looks like so

![rubrowser visualization](http://i.imgur.com/O2tbOJZ.png)

the idea is that the project opens every `.rb` file and parse it with `parser` gem then list all modules and classes definitions, and all constants that are listed inside this module/class and link them together, there are couple things you need to keep in mind:

* if your file doesn't have a valid ruby syntax it won't be parsed and will cause the gem to stop
* if you reference a class that is not defined in your project it won't be in the graph, we only display the graph of classes/modules you defined
* the server analyze your code once upon the script starts if you changed your code you'll have to restart rubrowser
* it statically analyze the code so meta programming is out of question in here
* rails associations are meta programming to forget it :smile:

## Usage

```
gem install rubrowser
rubrowser /path/to/project/or/file
```

it'll analyze the project and open port 9000, so you can access the graph from `localhost:9000`

## Features

* interactive graph, you can pull any node to fix it to some position
* to release node double click on it
* zoom and pan with mouse or touch pad


## Tests?

what test? :D

## Why?

Because i didn't find a good visualization tool to make me understand ruby projects when I join a new one.

it's great when you want to get into an open source project and visualize the structure to know where to work and the relations between modules/classes.
