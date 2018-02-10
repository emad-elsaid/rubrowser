$(document).on('click', '.card-header', function(){
  $(this).siblings().toggle();
});

// --------------------------------
// Details Panel
// --------------------------------
rubrowser.node.on('click', function(d){
  var namespace = d.id;
  var lines = d.lines;
  var dependents = rubrowser.relations.filter(function(i){ return i.target.id == namespace; });
  var dependencies = rubrowser.relations.filter(function(i){ return i.source.id == namespace; });
  var definitions = rubrowser.data.definitions.filter(function(i){ return i.namespace == namespace; });
  var relations = rubrowser.data.relations.filter(function(i){ return i.resolved_namespace == namespace || i.caller == namespace; });

  var content = $('<div>');
  content.append('<label><strong>'+namespace+' ('+d.lines+' Lines)</strong></label>');

  content.append('<strong>Defined in:</strong>');
  var definitions_ol = $("<ol>");
  for(var i=0; i<definitions.length; i++){
    definitions_ol.append("<li>"+definitions[i].file+":"+definitions[i].line.toString()+"</li>");
  }
  content.append(definitions_ol);

  if( dependents.length > 0 ){
    content.append('<strong>Dependents:</strong>');
    var dependents_ol = $("<ol>");
    for(var i=0; i<dependents.length; i++){
      dependents_ol.append("<li>"+dependents[i].source.id+"</li>");
    }
    content.append(dependents_ol);
  }

  if( dependencies.length > 0 ){
    content.append('<strong>Dependencies:</strong>');
    var dependencies_ol = $("<ol>");
    for(var i=0; i<dependencies.length; i++){
      dependencies_ol.append("<li>"+dependencies[i].target.id+"</li>");
    }
    content.append(dependencies_ol);
  }

  $('#information_panel').html(content);
  return true;
});


// --------------------------------
// Search Panel
// --------------------------------
$(document).on('change', '#highlight_by_namespace', function(){
  var highlights_entries = $(this).val().trim();
  var highlights = _(highlights_entries.split("\n"));

  rubrowser.node.classed('highlighted_by_namespace', function(d){
    if(highlights_entries.length == 0){ return false; }
    return highlights.some(function(i){ return d.id.indexOf(i) > -1; });
  });
});

$(document).on('change', '#highlight_by_file_path', function(){
  var highlights_entries = $(this).val().trim();
  var highlights = _(highlights_entries.split("\n"));

  rubrowser.node.classed('highlighted_by_path', function(d){
    if(highlights_entries.length == 0){ return false; }
    return highlights.some(function(i){
      return _(d.files).some(function(f) {
        return f.indexOf(i) > -1;
      });
    });
  });
});

$(document).on('change', '#highlight_modules, #highlight_classes', function(){
  var modules_highlighted = $('#highlight_modules').is(':checked'),
      classes_highlighted = $('#highlight_classes').is(':checked');

  rubrowser.node.classed('highlighted_by_type', function(d){
    return (d.type == 'Module' && modules_highlighted) || (d.type == 'Class' && classes_highlighted);
  });
});

// --------------------------------
// Ignore Panel
// --------------------------------
var ignoring_functions = {};

function updateNodes() {

  function ignoreNode(d) {
    return _(ignoring_functions).some(function(ignoring_function) {
      return ignoring_function(d);
    });
  }

  function notIgnoreNode(d){
    return !ignoreNode(d);
  }
  function ignoreRelation(r){
    return ignoreNode(r.source) || ignoreNode(r.target);
  }

  function notIgnoreRelation(r){
    return !ignoreRelation(r);
  }

  var filtered_definitions = rubrowser.definitions.filter(notIgnoreNode);
  rubrowser.simulation.nodes(filtered_definitions);
  rubrowser.node.classed('ignored', ignoreNode);

  var filtered_relations = rubrowser.relations.filter(notIgnoreRelation);
  rubrowser.simulation.force("link").links(filtered_relations);
  rubrowser.link.classed('ignored', ignoreRelation);
}

$(document).on('change', '#ignore_by_namespace', function(){
  var ignores_entries = $(this).val().trim();
  var ignores = ignores_entries.split("\n");

  if(ignores_entries.length == 0){
    delete ignoring_functions["ignore_by_name"];
  }else{
    ignoring_functions["ignore_by_name"] = function(d){
      return ignores.some(function(i){ return d.id.indexOf(i) > -1; });
    }
  }

  updateNodes();
});

$(document).on('change', '#ignore_by_file_path', function(){
  var ignores_entries = $(this).val().trim();
  var ignores = ignores_entries.split("\n");

  if(ignores_entries.length == 0){
    delete ignoring_functions["ignore_by_file_path"];
  }else{
    ignoring_functions["ignore_by_file_path"] = function(d){
      return ignores.some(function(i){
        return _(d.files).every(function(f){
          return f.indexOf(i) > -1;
        });
      });
    }
  }

  updateNodes();
});

$(document).on('change', '#ignore_modules, #ignore_classes', function(){
  var modules_ignored = $('#ignore_modules').is(':checked'),
      classes_ignored = $('#ignore_classes').is(':checked');

  if( modules_ignored ){
    ignoring_functions["ignore_modules"] = function(d) {
      return d.type == 'Module';
    }
  }else{
    delete ignoring_functions["ignore_modules"];
  }

  if( classes_ignored ){
    ignoring_functions["ignore_classes"] = function(d) {
      return d.type == 'Class';
    }
  }else{
    delete ignoring_functions["ignore_classes"];
  }

  updateNodes();
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

$(document).on('click', "#fix_all", function(){
  rubrowser.node.classed("fixed", true);
  rubrowser.node.each(function(d){
    d.fx = d.x;
    d.fy = d.y;
  });
});

$(document).on('click', "#release_all", function(){
  rubrowser.node.classed("fixed", false);
  rubrowser.node.each(function(d){
    delete d["fx"];
    delete d["fy"];
  });
});

$(document).on('click', "#download_layout", function(){
  var json = JSON.stringify(rubrowser.state.get());
  var element = document.createElement('a');
  element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(json));
  element.setAttribute('download', 'layout.json');

  element.style.display = 'none';
  document.body.appendChild(element);
  element.click();
  document.body.removeChild(element);
});
