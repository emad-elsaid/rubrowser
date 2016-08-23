# Rubrowser

a visualizer for ruby code (rails or otherwise), it analyze your code and extract the modules definitions and used classes/modules and render all these information as a directed force graph using D3.

this project is so small that the visualization looks like so

![rubrowser visualization](http://i.imgur.com/Lzjfbdk.png)


## Usage

for now you can clone it, get inside the directory and

```
bundle install
ruby rubrowser.rb /path/of/project/or/file
```

it'll analyze the project and open port 3000, so you can access the graph from `localhost:3000`

## Tests?

what test? :D

## Why?

Because i didn't find a good visualization tool to make me understand ruby projects when I join a new one.

it's great when you want to get into an open source project and visualize the structure to know where to work and the relations between modules/classes.
