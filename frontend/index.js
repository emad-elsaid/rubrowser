"use strict";
exports.__esModule = true;
var d3 = require("d3");
var $ = require("jquery");
var _ = require("lodash");
var Rubrowser = /** @class */ (function () {
    function Rubrowser(data) {
        var _this = this;
        this.data = data;
        this.max_circle_r = 50;
        this.svg = d3.select(".dependency_graph svg");
        this.$svg = $('.dependency_graph svg');
        this.width = this.$svg.width();
        this.height = this.$svg.height();
        var dup_definitions = data.definitions.map(function (d) {
            return {
                id: d.namespace,
                file: d.file,
                type: d.type,
                lines: d.lines,
                circular: d.circular
            };
        });
        this.definitions = _(dup_definitions).groupBy('id').map(function (group) {
            return {
                id: group[0].id,
                type: group[0].type,
                lines: _(group).sumBy('lines'),
                circular: group[0].circular,
                files: group.map(function (d) { return d.file; })
            };
        }).value();
        this.namespaces = this.definitions.map(function (d) { return d.id; });
        this.max_lines = _.maxBy(this.definitions, 'lines').lines;
        this.relations = data.relations.map(function (d) { return { source: d.caller, target: d.resolved_namespace, circular: d.circular }; });
        this.relations = this.relations.filter(function (d) {
            return _this.namespaces.indexOf(d.source) >= 0 && _this.namespaces.indexOf(d.target) >= 0;
        });
        this.relations = _.uniqWith(this.relations, _.isEqual);
        this.svg.call(this.zoom).on("dblclick.zoom", null);
        this.container = this.svg.append('g'),
            this.simulation = d3.forceSimulation()
                .force("link", d3.forceLink().id(function (d) { return d.id; }))
                .force("charge", d3.forceManyBody())
                .force("center", d3.forceCenter(this.width / 2, this.height / 2))
                .force("forceCollide", d3.forceCollide(80));
        this.simulation
            .nodes(this.definitions)
            .on("tick", this.ticked);
        this.simulation.force("link")
            .links(this.relations);
        this.link = this.container.append("g")
            .attr("class", "links")
            .selectAll("path")
            .data(this.relations)
            .enter().append("path")
            .attr("class", function (d) { return 'link ' + classForCircular(d); })
            .attr("marker-end", function (d) { return "url(#" + d.target.id + ")"; });
        this.node = this.container.append("g")
            .attr("class", "nodes")
            .selectAll("g")
            .data(this.definitions)
            .enter().append("g")
            .call(this.drag)
            .on("dblclick", this.dblclick);
        this.circle = this.node
            .append("circle")
            .attr("r", function (d) { return d.lines / _this.max_lines * _this.max_circle_r + 6; })
            .attr("class", function (d) { return classForCircular(d); });
        this.type = this.node
            .append("text")
            .attr("class", "type")
            .attr("x", "-0.4em")
            .attr("y", "0.4em")
            .text(function (d) { return d.type[0]; });
        this.text = this.node
            .append("text")
            .attr("class", "namespace")
            .attr("x", function (d) { return d.lines / _this.max_lines * _this.max_circle_r + 8; })
            .attr("y", ".31em")
            .text(function (d) { return d.id; });
        this.container.append("defs").selectAll("marker")
            .data(this.definitions)
            .enter().append("marker")
            .attr("id", function (d) { return d.id; })
            .attr("viewBox", "0 -5 10 10")
            .attr("refX", function (d) { return d.lines / _this.max_lines * _this.max_circle_r + 20; })
            .attr("refY", 0)
            .attr("markerWidth", 6)
            .attr("markerHeight", 6)
            .attr("orient", "auto")
            .append("path")
            .attr("d", "M0,-5L10,0L0,5");
        this.node.on('mouseover', function (d) {
            var relatives = [];
            this.link.classed('downlighted', function (l) {
                if (d === l.source || d === l.target) {
                    relatives.push(l.source);
                    relatives.push(l.target);
                    return false;
                }
                else {
                    return true;
                }
            });
            this.node.classed('downlighted', function (n) {
                return !(n == d || relatives.indexOf(n) > -1);
            });
        });
        this.node.on('mouseout', function () {
            this.link.classed('downlighted', false);
            this.node.classed('downlighted', false);
        });
    }
    Rubrowser.prototype.drag = function () {
        return d3.drag()
            .on("start", this.dragstarted)
            .on("drag", this.dragged)
            .on("end", this.dragended);
    };
    Rubrowser.prototype.dragstarted = function (d) {
        if (!d3.event.active)
            this.simulation.alphaTarget(0.3).restart();
        d3.select(d).classed("fixed", true);
        d.fx = d.x;
        d.fy = d.y;
    };
    Rubrowser.prototype.dragged = function (d) {
        d.fx = d3.event.x;
        d.fy = d3.event.y;
    };
    Rubrowser.prototype.dragended = function (d) {
        if (!d3.event.active) {
            this.simulation.alphaTarget(0);
        }
    };
    Rubrowser.prototype.dblclick = function (d) {
        d3.select(d).classed("fixed", false);
        d.fx = null;
        d.fy = null;
    };
    Rubrowser.prototype.zoom = function () {
        var _this = this;
        return d3.zoom().on("zoom", function () {
            _this.container.attr("transform", d3.event.transform);
        });
    };
    Rubrowser.prototype.ticked = function () {
        this.link.attr("d", this.linkArc);
        this.node.attr("transform", this.transform);
    };
    Rubrowser.prototype.linkArc = function (d) {
        var dr = 0;
        return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
    };
    Rubrowser.prototype.transform = function (d) {
        return "translate(" + d.x + "," + d.y + ")";
    };
    Rubrowser.prototype.getState = function () {
        var positions = [];
        this.definitions.forEach(function (elem) {
            if (elem.fx !== undefined && elem.fy !== undefined) {
                positions.push({
                    id: elem.id,
                    x: elem.fx,
                    y: elem.fy
                });
            }
        });
        return positions;
    };
    Rubrowser.prototype.setState = function (layout) {
        if (!layout) {
            return;
        }
        layout.forEach(function (pos) {
            var definition = this.node.filter(function (e) { return e.id == pos.id; });
            definition.classed("fixed", true);
            var datum = definition.data()[0];
            if (datum) {
                datum.fx = pos.x;
                datum.fy = pos.y;
            }
        });
    };
    return Rubrowser;
}());
;
function classForCircular(d) {
    return d.circular ? 'circular' : '';
}
;
var instance = new Rubrowser(data);
instance.setState(layout);
window["rubrowser"] = instance;
