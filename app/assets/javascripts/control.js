$(document).on("turbolinks:load", function() {
  if(window.location.pathname == '/controlling')
  {
      var groups = new vis.DataSet();
      var graph2d;

      function drawTestGraph(gpitems){
        var container = $(".graph")[0];
        var items = gpitems
        var machines = ["HF_Laser", "AbsauganlageLaser", "KuehlungLaser", "MechanikLaser", "Druckluft"];
        for(i = 0; i < 5; i++){
          groups.add({
            id: machines[i],
            content: machines[i]
          })
        }

        var dataset = new vis.DataSet(items);
        var options = {
          start: gpitems[0]['x'],
          end: gpitems[49]['x'],
          drawPoints: {
            style: 'circle', // square, circle
            size: 7
          },
          legend: true,
          shaded: {
            orientation: 'bottom' // top, bottom
          },
          dataAxis: {
            left: {
              title: {
                text: 'Spannung(Durchschnitt) in 0.01V'
              }
            }
          }
        };
        graph2d = new vis.Graph2d(container, dataset, groups ,options);
      }

      drawTestGraph(gon.graphData);

      $(".machine-checkbox > label > input").on('change', function(){
        var cls = $(this).attr("class");
        if($(this).is(":checked")){
          graph2d.setOptions({
              groups:{
                  visibility:{
                      "HF_Laser": true
                  }
              }
          });
        } else {
           graph2d.setOptions({
               groups:{
                   visibility:{
                       "HF_Laser": false
                   }
               }
           });
       }
      });
  }
});
