$(document).on("turbolinks:load", function() {
  if(window.location.pathname == '/controlling')
  {
      function drawTestGraph(gpitems){
        var container = $(".graph")[0];
        var items = gpitems

        var dataset = new vis.DataSet(items);
        var options = {
          start: gpitems[0]['x'],
          end: gpitems[9]['x'],
          dataAxis: {
            left: {
              title: {
                text: 'Spannung(Durchschnitt) in 0.01V'
              }
            }
          }
        };
        var graph2d = new vis.Graph2d(container, dataset, options);
      }

      drawTestGraph(gon.graphData);
  }
});
