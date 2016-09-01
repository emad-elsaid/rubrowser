$(document).on('click', '.panel .title', function(){
  $(this).siblings().toggle();
});

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
