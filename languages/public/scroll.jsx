    // using d3 for convenience
    var container = d3.select('#scroll');
    var graphic = container.select('.scroll__graphic');
    var text = container.select('.scroll__text');
    var step = text.selectAll('.step');
    // initialize the scrollama
    var scroller = scrollama();
    // generic window resize listener event
    function handleResize() {
      // 1. update height of step elements
      var stepHeight = Math.floor(window.innerHeight * 0.75);
      step.style('height', stepHeight + 'px');
      // 2. update width/height of graphic element
      var bodyWidth = d3.select('body').node().offsetWidth;
      var graphicMargin = 16 * 4;
      var textWidth = text.node().offsetWidth;
      var graphicWidth = container.node().offsetWidth - textWidth - graphicMargin;
      var graphicHeight = Math.floor(window.innerHeight / 2)
      var graphicMarginTop = Math.floor(graphicHeight / 2)
      graphic
        .style('width', graphicWidth + 'px')
        .style('height', graphicHeight + 'px')
        .style('top', graphicMarginTop + 'px');
      // 3. tell scrollama to update new element dimensions
      scroller.resize();
    }
    // scrollama event handlers
    function handleStepEnter(response) {
      // response = { element, direction, index }
      // add color to current step only
      console.log("BROOO");
      if (response.index != 1) d3.select("svg").remove(); 
      step.classed('is-active', function (d, i) {
        return i === response.index;
      })
      // update graphic based on step
      graphic.select('p').text(response.index + 1);
    }
    function handleContainerEnter(response) {
                    console.log("hihih");

      // response = { direction }
    }
    function handleContainerExit(response) {
      // response = { direction }
    }
    function setupStickyfill() {
      d3.selectAll('.sticky').each(function () {
        Stickyfill.add(this);
      });
    }
    function init() {
      setupStickyfill();
      // 1. force a resize on load to ensure proper dimensions are sent to scrollama
      handleResize();
      // 2. setup the scroller passing options
      // this will also initialize trigger observations
      // 3. bind scrollama event handlers (this can be chained like below)
      scroller.setup({
        container: '#scroll',
        graphic: '.scroll__graphic',
        text: '.scroll__text',
        step: '.scroll__text .step',
        debug: true,
        offset: 0.33,
      })
        .onStepEnter(handleStepEnter)
        .onContainerEnter(handleContainerEnter)
        .onContainerExit(handleContainerExit);
      // setup resize event
      window.addEventListener('resize', handleResize);
    }
    // kick things off
    init();