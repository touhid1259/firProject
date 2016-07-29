$(document).ready(function() {
  if(window.location.pathname == '/energy')
  {
      $.simpleWeather({
        // location: 'campus melaten, aachen, germany',
        woeid: '20066562',
        unit: 'c',
        success: function(weather) {
          html = '<h2><i class="icon-'+weather.code+'"></i> '+weather.temp+'&deg;'+weather.units.temp+'<img src="' +weather.thumbnail+ '"></h2>';
          html += '<ul><li><b>Location:</b> Campus Melaten, '+weather.city+', '+weather.region+'</li>';
          html += '<li class="currently"><b>Current Condition:</b> '+weather.currently+'</li>';
          html += '<li class="currently"><b>Humidity:</b> '+weather.humidity+'%</li>';
          html += '<li><b>Wind Status:</b> '+weather.wind.direction+' '+weather.wind.speed+' '+weather.units.speed+'</li></ul>';

          $(".weather").html(html);
        },
        error: function(error) {
          $(".weather").html('<p>'+error+'</p>');
        }
      });

      $('.fact').on('click', function(){
        $('.choose-machine').dialog();
      });
  }

  if(window.location.pathname == '/energy/printer')
  {
      function drawPrinterGraph(gpitems){
        var container = $(".printer-graph")[0];
        var items = gpitems

        var dataset = new vis.DataSet(items);
        var options = {
          start: gpitems[30]['x'],
          end: gpitems[49]['x'],
          dataAxis: {
            left: {
              title: {
                text: 'Power'
              }
            }
          }
        };
        var graph2d = new vis.Graph2d(container, dataset, options);
      }

      drawPrinterGraph(gon.graphData);
  }

});
