var classForCircular = function(d) {
  return d.circular ? 'circular' : '';
};

var svg = d3.select(".dependency_graph svg"),
    $svg = $('.dependency_graph svg'),
    width = $svg.width(),
    height = $svg.height(),
    drag = d3.drag()
    .on("start", dragstarted)
    .on("drag", dragged)
    .on("end", dragended),
    dup_definitions = data.definitions.map(function(d){
      return {
        id: d.namespace,
        file: d.file,
        type: d.type,
        lines: d.lines,
        circular: d.circular
      };
    }),
    definitions = _(dup_definitions).groupBy('id').map(function(group) {
      return {
        id: group[0].id,
        type: group[0].type,
        lines: _(group).sumBy('lines'),
        circular: group[0].circular,
        files: group.map(function(d){ return d.file; })
      };
    }).value(),
    namespaces = definitions.map(function(d){ return d.id; }),
    relations = data.relations.map(function(d){ return {source: d.caller, target: d.resolved_namespace, circular: d.circular}; }),
    max_lines = _.maxBy(definitions, 'lines').lines,
    max_circle_r = 50;

relations = relations.filter(function(d){
  return namespaces.indexOf(d.source) >= 0 && namespaces.indexOf(d.target) >= 0;
});
relations = _.uniqWith(relations, _.isEqual);

var zoom = d3.zoom()
    .on("zoom", function () {
      container.attr("transform", d3.event.transform);
    });

svg.call(zoom)
  .on("dblclick.zoom", null);

var container = svg.append('g'),
    simulation = d3.forceSimulation()
    .force("link", d3.forceLink().id(function(d) { return d.id; }))
    .force("charge", d3.forceManyBody())
    .force("center", d3.forceCenter(width / 2, height / 2))
    .force("forceCollide", d3.forceCollide(80));

simulation
  .nodes(definitions)
  .on("tick", ticked);

simulation.force("link")
  .links(relations);

var link = container.append("g")
    .attr("class", "links")
    .selectAll("path")
    .data(relations)
    .enter().append("path")
    .attr("class", function(d) { return 'link ' + classForCircular(d); })
    .attr("marker-end", function(d){ return "url(#" + d.target.id + ")"; }),
    node = container.append("g")
    .attr("class", "nodes")
    .selectAll("g")
    .data(definitions)
    .enter().append("g")
    .call(drag)
    .on("dblclick", dblclick),
    circle = node
    .append("circle")
    .attr("r", function(d) { return d.lines / max_lines * max_circle_r + 6; })
    .attr("class", function (d) { return classForCircular(d) ; }),
    type = node
    .append("text")
    .attr("class", "type")
    .attr("x", "-0.4em")
    .attr("y", "0.4em")
    .text(function(d) { return d.type[0]; }),
    text = node
    .append("text")
    .attr("class", "namespace")
    .attr("x", function(d) { return d.lines / max_lines * max_circle_r + 8; })
    .attr("y", ".31em")
    .text(function(d) { return d.id; });

container.append("defs").selectAll("marker")
  .data(definitions)
  .enter().append("marker")
  .attr("id", function(d) { return d.id; })
  .attr("viewBox", "0 -5 10 10")
  .attr("refX", function(d){ return d.lines / max_lines * max_circle_r + 20; })
  .attr("refY", 0)
  .attr("markerWidth", 6)
  .attr("markerHeight", 6)
  .attr("orient", "auto")
  .append("path")
  .attr("d", "M0,-5L10,0L0,5");

function ticked() {
  link.attr("d", linkArc);
  node.attr("transform", transform);
}

function linkArc(d) {
  var dx = d.target.x - d.source.x,
      dy = d.target.y - d.source.y,
      dr =  0;
  return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
}

function dragstarted(d) {
  if (!d3.event.active) simulation.alphaTarget(0.3).restart();
  d3.select(this).classed("fixed", true);
  d.fx = d.x;
  d.fy = d.y;
}

function dragged(d) {
  d.fx = d3.event.x;
  d.fy = d3.event.y;
}

function dragended(d) {
  if (!d3.event.active) simulation.alphaTarget(0);
}

function dblclick(d) {
  d3.select(this).classed("fixed", false);
  d.fx = null;
  d.fy = null;
}

function transform(d) {
  return "translate(" + d.x + "," + d.y + ")";
}

var state = {
  get: function(){
    var positions = [];
    rubrowser.definitions.forEach(function(elem){
      if( elem.fx !== undefined && elem.fy !== undefined) {
        positions.push({
          id: elem.id,
          x: elem.fx,
          y: elem.fy
        });
      }
    });
    return positions;
  },

  set: function(layout){
    if ( !layout ) { return; }
    layout.forEach(function(pos) {
      var definition = node.filter(function(e) { return e.id == pos.id; })
      definition.classed("fixed", true);

      var datum = definition.data()[0]
      if( datum ) {
        datum.fx = pos.x
        datum.fy = pos.y
      }
    });
  }
}

node.on('mouseover', function(d) {
  var relatives = [];
  link.classed('downlighted', function(l) {
    if (d === l.source || d === l.target){
      relatives.push(l.source);
      relatives.push(l.target);
      return false;
    }else{
      return true;
    }
  });
  node.classed('downlighted', function(n) {
    return !(n == d || relatives.indexOf(n) > -1);
  });
});

node.on('mouseout', function() {
  link.classed('downlighted', false);
  node.classed('downlighted', false);
});

window.rubrowser = {
  data: data,
  definitions: definitions,
  relations: relations,
  simulation: simulation,
  node: node,
  link: link,
  state: state
};

rubrowser.state.set(layout);
