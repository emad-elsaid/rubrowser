$(document).on('click', '.panel .title', function(){
  $(this).siblings().toggle();
});

// --------------------------------
// Search Panel
// --------------------------------
$(document).on('change', '#highlight_by_namespace', function(){
  var highlights_entries = $(this).val().trim();
  var highlights = highlights_entries.split("\n");

  rubrowser.node.classed('name_highlighted', function(d){
    if(highlights_entries.length == 0){ return false; }
    return highlights.filter(function(i){ return d.id.indexOf(i) > -1; }).length > 0;
  });
});

$(document).on('change', '#highlight_modules, #highlight_classes', function(){
  var modules_highlighted = $('#highlight_modules').is(':checked'),
      classes_highlighted = $('#highlight_classes').is(':checked');

  rubrowser.node.classed('type_highlighted', function(d){
    return (d.type == 'Module' && modules_highlighted) || (d.type == 'Class' && classes_highlighted);
  });
});

// --------------------------------
// Ignore Panel
// --------------------------------
$(document).on('change', '#ignore_by_namespace', function(){
  var ignores_entries = $(this).val().trim();
  var ignores = ignores_entries.split("\n");

  rubrowser.node.classed('name_ignored', function(d){
    if(ignores_entries.length == 0){ return false; }
    return ignores.filter(function(i){ return d.id.indexOf(i) > -1; }).length > 0;
  });
  rubrowser.link.classed('name_ignored', function(d){
    if(ignores_entries.length == 0){ return false; }
    return ignores.filter(function(i){ return d.source.id.indexOf(i) > -1 || d.target.id.indexOf(i) > -1; }).length > 0;
  });
});

$(document).on('change', '#ignore_modules, #ignore_classes', function(){
  var modules_ignored = $('#ignore_modules').is(':checked'),
      classes_ignored = $('#ignore_classes').is(':checked');

  rubrowser.node.classed('type_ignored', function(d){
    return (d.type == 'Module' && modules_ignored) || (d.type == 'Class' && classes_ignored);
  });
  rubrowser.link.classed('type_ignored', function(d){
    return ((d.source.type == 'Module' && modules_ignored) || (d.source.type == 'Class' && classes_ignored)) ||
      ((d.target.type == 'Module' && modules_ignored) || (d.target.type == 'Class' && classes_ignored));
  });
});

// --------------------------------
// Display Panel
// --------------------------------
$(document).on('change', "#force_collide", function(){
  var new_value = $(this).val();
  rubrowser.simulation.force("forceCollide", d3.forceCollide(new_value));
});

$(document).on('change', "#hide_relations", function(){
  var hide_relations = $('#hide_relations').is(':checked');
  rubrowser.link.classed("hide_relation", hide_relations);
});

$(document).on('change', "#hide_namespaces", function(){
  var hide_namespaces = $('#hide_namespaces').is(':checked');
  rubrowser.node.classed("hide_namespace", hide_namespaces);
});

$(document).on('click', "#pause_simulation", function(){
    rubrowser.simulation.stop();
});
