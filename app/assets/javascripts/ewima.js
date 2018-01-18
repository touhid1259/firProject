$(document).on("turbolinks:load", function() {
  if(window.location.pathname == '/ewima/preference_selection')
  {

      function drawPreferenceGraph(gpitems, container){
        var graph2d;
        var dataset = new vis.DataSet(gpitems); // x and y axis data array for the graph2d
        var groups = new vis.DataSet();
        groups.add({
          id: 0,
          content: "v1"
        });
        groups.add({
          id: 1,
          content: "v2"
        });

        var options = {
          start: gpitems[0]['x'],
          end: gpitems[63]['x'],
          drawPoints: {
            style: 'circle', // square, circle
            size: 3
          },
          height: "265px",
          shaded: {
            orientation: 'bottom' // top, bottom
          },
          legend: true,
          showCurrentTime: false,
          dataAxis: {
            left: {
              title: {
                text: 'belt velocity'
              }
            }
          }
        };

        graph2d = new vis.Graph2d(container, dataset, groups, options);
        graph2d.fit();

      }

      drawPreferenceGraph(gon.dataToVisualizeOne, $(".preference-graph-one")[0]);
      drawPreferenceGraph(gon.dataToVisualizeTwo, $(".preference-graph-two")[0]);
      drawPreferenceGraph(gon.dataToVisualizeThree, $(".preference-graph-three")[0]);
      drawPreferenceGraph(gon.dataToVisualizeFour, $(".preference-graph-four")[0]);

  }

// ===================================================================================

  if(window.location.pathname == '/ewima/summary')
  {
    function drawGraph(gpitems, container, yAxisValue, groupContent, groupClassName){
      var graph2d;
      var dataset = new vis.DataSet(gpitems); // x and y axis data array for the graph2d
      var groups = new vis.DataSet();
      groups.add({
        id: 0,
        content: groupContent[0],
      });
      groups.add({
        id: 1,
        content: groupContent[1],
      });
      groups.add({
        id: 2,
        content: groupContent[0],
        className: groupClassName
      });

      var options = {
        start: gpitems[0]['x'],
        drawPoints: {
          style: 'circle', // square, circle
          size: 3
        },
        height: "265px",
        shaded: {
          orientation: 'bottom' // top, bottom
        },
        legend: true,
        showCurrentTime: false,
        dataAxis: {
          left: {
            title: {
              text: yAxisValue
            }
          }
        }
      };

      graph2d = new vis.Graph2d(container, dataset, groups, options);
      graph2d.fit();

    }

    drawGraph(gon.optimalGraphData, $(".optimal-graph")[0], "belt velocity", ["v1", "v2"], "");
    drawGraph(gon.energyConsumptionData, $(".energy-consumption-graph")[0], "power", ["power", ""], "cls-energy-power");
    drawGraph(gon.energyPriceData, $(".energy-price-graph")[0], "energy price", ["price", ""], "cls-energy-price");

  }

// ===================================================================================

  if(window.location.pathname == '/ewima/rough_planning')
  {
    function drawGraph(gpitems, container){
      var graph2d;
      var dataset = new vis.DataSet(gpitems); // x and y axis data array for the graph2d
      var groups = new vis.DataSet();

      var options = {
        start: gpitems[0]['x'],
        drawPoints: {
          style: 'circle', // square, circle
          size: 3
        },
        height: "120px",
        shaded: {
          orientation: 'bottom' // top, bottom
        },
        showCurrentTime: false,
        dataAxis: {
          left: {
            title: {
              text: "waste"
            }
          }
        }
      };

      graph2d = new vis.Graph2d(container, dataset, groups, options);
      graph2d.fit();
    }

    drawGraph(gon.dataForTunnelOne, $(".rough-tunnel-one")[0]);
    drawGraph(gon.dataForTunnelTwo, $(".rough-tunnel-two")[0]);
    drawGraph(gon.dataForTunnelThree, $(".rough-tunnel-three")[0]);
    drawGraph(gon.dataForTunnelFour, $(".rough-tunnel-four")[0]);
    drawGraph(gon.dataForTunnelFive, $(".rough-tunnel-five")[0]);
  }


});
