<template>
  <div class="Content"></div>
</template>

<script>

import * as d3 from '../../../public/d3/d3.v4.min'

export default {
  name: 'ManageEAV',

  metaInfo () {
    return {
      title:         'ManageEAV',
      titleTemplate: '%s - ' + this.$t('app.title'),
      meta:          [{
        name: 'token', content: localStorage.getItem('token')
      }],
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  mounted () {

    // proxy for localhost
    const host   = window.location.hostname
    let apiProxy = ''
    if (host === 'localhost') {
      apiProxy = 'https://cors-c.herokuapp.com/https://freee.su'
    }
    const url = apiProxy + '/manage_eav/root'

    // treeJSON = d3.json("/d3/root.json", function(error, treeData) {
    const treeJSON = d3.json(url, (error, treeData) => {
      // Set the dimensions and margins of the diagram
      let radius = 8
      // Set the dimensions and margins of the diagram
      let margin = {top: 0, right: 0, bottom: 0, left: 40}
      // var width = 960 - margin.left - margin.right;
      // var height = 500 - margin.top - margin.bottom;
      let div    = document.getElementsByClassName('Content')[0]
      //let height = document.getElementsByClassName('Content')[0]
      let width  = div.offsetWidth
      let height = div.offsetHeight

      // append the svg object to the body of the page
      // appends a 'group' element to 'svg'
      // moves the 'group' element to the top left margin
      let svg = d3.select('.Content').append('svg')
                  .attr('width', width + margin.right + margin.left)
                  .attr('height', height + margin.top + margin.bottom)
                  .append('g')
                  .attr('transform', 'translate('
                    + margin.left + ',' + margin.top + ')')

      let i        = 0,
          duration = 180,
          root

      // declares a tree layout and assigns the size
      let treemap = d3.tree().size([height, width])

      // Assigns parent, children, height, depth
      root    = d3.hierarchy(treeData, (d) => d.children)
      root.x0 = height / 2
      root.y0 = 0

      // Collapse after the second level
      root.children.forEach(collapse)

      update(root)

      // Collapse the node and all it's children
      function collapse (d) {
        if (d.children) {
          d._children = d.children
          d._children.forEach(collapse)
          d.children = null
        }
      }

      function update (source) {

        // Assigns the x and y position for the nodes
        let treeData = treemap(root)

        // Compute the new tree layout.
        let nodes = treeData.descendants(),
            links = treeData.descendants().slice(1)

        // Normalize for fixed-depth.
        nodes.forEach(function (d) { d.y = d.depth * 80})

        // ****************** Nodes section ***************************

        // Update the nodes...
        let node = svg.selectAll('g.node')
                      .data(nodes, function (d) {return d.id || (d.id = ++i) })

        // Enter any new modes at the parent's previous position.
        let nodeEnter = node.enter().append('g')
                            .attr('class', 'node')
                            .attr('transform', function (d) {
                              return 'translate(' + source.y0 + ',' + source.x0 + ')'
                            })
                            .on('click', click)

        // Add Circle for the nodes
        nodeEnter.append('circle')
                 .attr('class', 'node')
                 .attr('r', 1e-6)
                 .style('fill', function (d) {
                   return d._children ? 'lightsteelblue' : '#ffffff'
                 })

        // Add labels for the nodes
        nodeEnter.append('text')
                 .attr('dy', '.10em')
                 .attr('x', function (d) {
                   return d.children || d._children ? -13 : 13
                 })
                 .attr('text-anchor', function (d) {
                   return d.children || d._children ? 'end' : 'start'
                 })
                 .text(function (d) { return d.data.name })

        // UPDATE
        var nodeUpdate = nodeEnter.merge(node)

        // Transition to the proper position for the node
        nodeUpdate.transition()
                  .duration(duration)
                  .attr('transform', function (d) {
                    return 'translate(' + d.y + ',' + d.x + ')'
                  })

        // Update the node attributes and style
        nodeUpdate.select('circle.node')
                  .attr('r', radius)
                  .style('fill', function (d) {
                    return d._children ? 'lightsteelblue' : '#ffffff'
                  })
                  .attr('cursor', 'pointer')

        // Remove any exiting nodes
        let nodeExit = node.exit().transition()
                           .duration(duration)
                           .attr('transform', function (d) {
                             return 'translate(' + source.y + ',' + source.x + ')'
                           })
                           .remove()

        // On exit reduce the node circles size to 0
        nodeExit.select('circle')
                .attr('r', 1e-6)

        // On exit reduce the opacity of text labels
        nodeExit.select('text')
                .style('fill-opacity', 1e-6)

        // ****************** links section ***************************

        // Update the links...
        let link = svg.selectAll('path.link')
                      .data(links, function (d) { return d.id })

        // Enter any new links at the parent's previous position.
        let linkEnter = link.enter().insert('path', 'g')
                            .attr('class', 'link')
                            .attr('d', function (d) {
                              var o = {x: source.x0, y: source.y0}
                              return diagonal(o, o)
                            })

        // UPDATE
        let linkUpdate = linkEnter.merge(link)

        // Transition back to the parent element position
        linkUpdate.transition()
                  .duration(duration)
                  .attr('d', function (d) { return diagonal(d, d.parent) })

        // Remove any exiting links
        let linkExit = link.exit().transition()
                           .duration(duration)
                           .attr('d', function (d) {
                             var o = {x: source.x, y: source.y}
                             return diagonal(o, o)
                           })
                           .remove()

        // Store the old positions for transition.
        nodes.forEach(function (d) {
          d.x0 = d.x
          d.y0 = d.y
        })

        // Creates a curved (diagonal) path from parent to the child nodes
        function diagonal (s, d) {

          path = `M ${s.y} ${s.x}
                C ${(s.y + d.y) / 2} ${s.x},
                  ${(s.y + d.y) / 2} ${d.x},
                  ${d.y} ${d.x}`

          return path
        }

        // Toggle children on click.
        function click (d) {
          console.log(d)
          if (d.children) {
            d._children = d.children
            d.children  = null
          }
          else {
            d.children  = d._children
            d._children = null
          }
          update(d)
        }
      }
    })
  },

  data () {
    return {}
  }
}
</script>

<style lang="sass"
       scoped>
.node
  cursor: pointer


.node circle
  fill: #ffffff
  stroke: steelblue
  stroke-width: 1px


.node text
  font: 13px sans-serif
  cursor: pointer


.link
  fill: none
  stroke: #dddddd
  stroke-width: 1px


.Content
  height: 100%
  width: 95%
  padding-left: 0
  border-top-width: 0px
  border-right-width: 0px
  border-bottom-width: 0px
  border-left-width: 0px
  margin-inline-start: auto
  margin-inline-end: auto
  -webkit-border-horizontal-spacing: 0px
  -webkit-border-vertical-spacing: 0px

</style>
