$(document).on("turbolinks:load", function() {
  if(window.location.pathname == '/controlling')
  {
      var groups = new vis.DataSet();
      var graph2d;
      var machines = ["HF_Laser", "AbsauganlageLaser", "KuehlungLaser", "MechanikLaser", "Druckluft"];

      function drawTestGraph(gpitems){
        var container = $(".graph")[0];
        var items = gpitems;
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
        var cls_true = {};
        var cls_false = {};
        cls_true[cls] = true;
        cls_false[cls] = false;

        if($(this).is(":checked")){
          graph2d.setOptions({
              groups:{
                  visibility: cls_true
              }
          });
        } else {
           graph2d.setOptions({
               groups:{
                   visibility: cls_false
               }
           });
       }
      });

      graph2d.on("click", function(prop){
        console.log(prop);

      });
  }
});
