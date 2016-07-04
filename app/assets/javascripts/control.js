if(window.location.pathname == '/controlling')
{
  $(document).ready(function() {
    function drawTestGraph(gpitems){
      var container = $(".graph")[0];
      // var items = [
      //   {x: '2014-06-11', y: 10},
      //   {x: '2014-06-12', y: 25},
      //   {x: '2014-06-13', y: 30},
      //   {x: '2014-06-14', y: 10},
      //   {x: '2014-06-15', y: 15},
      //   {x: '2014-06-16', y: 30}
      // ];
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
  });
}
