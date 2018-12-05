import * as d3 from 'd3';
import * as $ from 'jquery';
import * as _ from 'lodash';

interface Definition {
    id: string
    type: string
    namespace?: string
    circular: boolean
    file?: string
    line?: number
    lines: number
    fx?: number
    fy?: number
}

interface Relation {
    line: number
    circular: boolean
    file: string
    caller: string
    resolved_namespace: string
    namespace: string
    type: string
}

interface Data {
    definitions: Definition[]
    relations: Relation[]
}

interface D3Link {
    source: string
    target: string
    circular: boolean
}

class Rubrowser {
    simulation: any
    node: any
    state: any
    svg: any
    $svg: any
    width: number
    height: number
    container: any
    max_circle_r: number = 50
    namespaces: string[]
    relations: D3Link[]
    max_lines: number
    link: any
    circle: any
    type: any
    text: any
    definitions: Definition[]


    constructor(public data: Data) {
        this.svg = d3.select(".dependency_graph svg");
        this.$svg = $('.dependency_graph svg');
        this.width = this.$svg.width();
        this.height = this.$svg.height();

        let dup_definitions = data.definitions.map(function(d){
            return {
                id: d.namespace,
                file: d.file,
                type: d.type,
                lines: d.lines,
                circular: d.circular
            };

        })

        this.definitions = _(dup_definitions).groupBy('id').map(function(group) {
            return {
                id: group[0].id,
                type: group[0].type,
                lines: _(group).sumBy('lines'),
                circular: group[0].circular,
                files: group.map(function(d){ return d.file; })
            };
        }).value()

        this.namespaces = this.definitions.map(function(d){ return d.id; });
        this.max_lines = _.maxBy(this.definitions, 'lines').lines;

        this.relations = data.relations.map(function(d): D3Link { return { source: d.caller, target: d.resolved_namespace, circular: d.circular }; });
        this.relations = this.relations.filter((d) => {
            return this.namespaces.indexOf(d.source) >= 0 && this.namespaces.indexOf(d.target) >= 0;
        });
        this.relations = _.uniqWith(this.relations, _.isEqual);

        this.svg.call(this.zoom).on("dblclick.zoom", null);

        this.container = this.svg.append('g'),
        this.simulation = d3.forceSimulation()
            .force("link", d3.forceLink().id(function(d: {id: string}) { return d.id; }))
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
            .attr("class", (d) => { return 'link ' + classForCircular(d); })
            .attr("marker-end", (d) => { return "url(#" + d.target.id + ")"; })

        this.node = this.container.append("g")
            .attr("class", "nodes")
            .selectAll("g")
            .data(this.definitions)
            .enter().append("g")
            .call(this.drag)
            .on("dblclick", this.dblclick)

        this.circle = this.node
            .append("circle")
            .attr("r", (d) => { return d.lines / this.max_lines * this.max_circle_r + 6; })
            .attr("class", (d) => { return classForCircular(d) ; })

        this.type = this.node
            .append("text")
            .attr("class", "type")
            .attr("x", "-0.4em")
            .attr("y", "0.4em")
            .text(function(d) { return d.type[0]; })

        this.text = this.node
            .append("text")
            .attr("class", "namespace")
            .attr("x", (d) => { return d.lines / this.max_lines * this.max_circle_r + 8; })
            .attr("y", ".31em")
            .text(function(d) { return d.id; });

        this.container.append("defs").selectAll("marker")
            .data(this.definitions)
            .enter().append("marker")
            .attr("id", function(d) { return d.id; })
            .attr("viewBox", "0 -5 10 10")
            .attr("refX", (d) => { return d.lines / this.max_lines * this.max_circle_r + 20; })
            .attr("refY", 0)
            .attr("markerWidth", 6)
            .attr("markerHeight", 6)
            .attr("orient", "auto")
            .append("path")
            .attr("d", "M0,-5L10,0L0,5");

        this.node.on('mouseover', function(d) {
            let relatives = [];
            this.link.classed('downlighted', function(l) {
                if (d === l.source || d === l.target){
                    relatives.push(l.source);
                    relatives.push(l.target);
                    return false;
                }else{
                    return true;
                }
            });
            this.node.classed('downlighted', function(n) {
                return !(n == d || relatives.indexOf(n) > -1);
            });
        });

        this.node.on('mouseout', function() {
            this.link.classed('downlighted', false);
            this.node.classed('downlighted', false);
        });


    }

    drag() {
        return d3.drag()
            .on("start", this.dragstarted)
            .on("drag", this.dragged)
            .on("end", this.dragended);
    }

    dragstarted(d) {
        if (!d3.event.active) this.simulation.alphaTarget(0.3).restart();
        d3.select(d).classed("fixed", true);
        d.fx = d.x;
        d.fy = d.y;
    }

    dragged(d) {
        d.fx = d3.event.x;
        d.fy = d3.event.y;
    }

    dragended(d) {
        if (!d3.event.active) {
            this.simulation.alphaTarget(0);
        }
    }

    dblclick(d) {
        d3.select(d).classed("fixed", false);
        d.fx = null;
        d.fy = null;
    }

    zoom() {
        return d3.zoom().on("zoom", () => {
            this.container.attr("transform", d3.event.transform);
        });
    }

    ticked() {
        this.link.attr("d", this.linkArc);
        this.node.attr("transform", this.transform);
    }

    linkArc(d) {
        let dr =  0;
        return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
    }

    transform(d) {
        return "translate(" + d.x + "," + d.y + ")";
    }

    getState() {
        var positions = [];
        this.definitions.forEach(function(elem){
            if( elem.fx !== undefined && elem.fy !== undefined) {
                positions.push({
                    id: elem.id,
                    x: elem.fx,
                    y: elem.fy
                });
            }
        });
        return positions;
    }

    setState(layout) {
        if ( !layout ) { return; }
        layout.forEach(function(pos) {
            var definition = this.node.filter(function(e) { return e.id == pos.id; })
            definition.classed("fixed", true);

            var datum = definition.data()[0]
            if( datum ) {
                datum.fx = pos.x
                datum.fy = pos.y
            }
        });
    }
};


function classForCircular(d): string {
  return d.circular ? 'circular' : '';
};

declare var data: Data;
declare var layout: any;

let instance: Rubrowser = new Rubrowser(data);
instance.setState(layout);

window["rubrowser"] = instance;
