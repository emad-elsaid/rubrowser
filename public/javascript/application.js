var ParseGraph = function(){
  var svg = d3.select(".dependency_graph svg");
  var $svg = $('.dependency_graph svg').html('');

  if(!svg.size()){
    return false;
  }

  var width = $svg.width(),
      height = $svg.height(),
      constants = JSON.parse(svg.attr('data-constants')),
      occurences = JSON.parse(svg.attr('data-occurences'));
  var color = d3.scaleOrdinal(d3.schemeCategory20);

  var simulation = d3.forceSimulation()
        .force("link", d3.forceLink().id(function(d) { return d.id; }))
        .force("charge", d3.forceManyBody())
        .force("center", d3.forceCenter(width / 2, height / 2))
        .force("forceCollide", d3.forceCollide(function(){ return 80; }));

  var link = svg.append("g")
        .attr("class", "links")
        .selectAll("line")
        .data(occurences)
        .enter().append("line")
        .attr("stroke-width", 1);

  var node = svg.append("g")
        .attr("class", "nodes")
        .selectAll("text")
        .data(constants)
        .enter().append("text")
          .text(function(d){ return d.name; })
          .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended));

  simulation
      .nodes(constants)
      .on("tick", ticked);

  simulation.force("link")
      .links(occurences);

  function ticked() {
    link
      .attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });

    node
      .attr("x", function(d) { return d.x; })
      .attr("y", function(d) { return d.y; });
  }

  function dragstarted(d) {
    if (!d3.event.active) simulation.alphaTarget(0.3).restart();
    d.fx = d.x;
    d.fy = d.y;
  }

  function dragged(d) {
    d.fx = d3.event.x;
    d.fy = d3.event.y;
  }

  function dragended(d) {
    if (!d3.event.active) simulation.alphaTarget(0);
    d.fx = null;
    d.fy = null;
  }

  return true;

};

$(function(){ParseGraph();});
