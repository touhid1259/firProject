$(document).on("turbolinks:load", function() {
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

      $('.printer-link').on('click', function(){
        $('#machineries-modal').modal('hide');
        window.location.href = "/energy/printer";
      });
  }

  if(window.location.pathname == '/energy/printer')
  {
      var graph2d;
      var dataset; // x and y axis data array for the graph2d

      function drawPrinterGraph(gpitems){
        var container = $(".printer-graph")[0];
        var items = gpitems
        // var groups = new vis.DataSet();
        // groups.add({
        //     id: 0,
        //     content: '< 18',
        // });
        //
        // groups.add({
        //     id: 1,
        //     content: '> 18',
        //     className: 'power-more-20',
        // });

        dataset = new vis.DataSet(items);
        var options = {
          start: gpitems[0]['x'],
          end: gpitems[49]['x'],
          drawPoints: {
            style: 'circle' // square, circle
          },
          shaded: {
            orientation: 'bottom' // top, bottom
          },
          dataAxis: {
            left: {
              title: {
                text: 'Power'
              }
            }
          }
        };

        graph2d = new vis.Graph2d(container, dataset, options);
        console.log(graph2d.getWindow());
      }

      drawPrinterGraph(gon.graphData);

      /**
       * Add a new datapoint to the graph
       */
      function addDataPoint(time, power) {
        // add a new data point to the dataset
        dataset.add({
          x: time,
          y: power,
          // group: (power < 18) ? 0 : 1
        });

        // remove all data points which are no longer visible
        var range = graph2d.getWindow();
        var interval = range.end - range.start;
        var oldIds = dataset.getIds({
          filter: function (item) {
            var jstime = new Date(item.x);
            return jstime < range.start - interval ;
          }
        });

        dataset.remove(oldIds);
      }

      function renderStep(time) {
        // move the window (you can think of different strategies).
        var xtime = time;
        var range = graph2d.getWindow();
        var interval = range.end - range.start;

        graph2d.setWindow(xtime - interval, xtime, {animation: false});

      }

      // var sec = 2;
      var source = new EventSource('/energy/printer/continuous');
      source.addEventListener('time', function(event) {
        if(window.location.pathname != '/energy/printer'){
          source.close();
        }

        var json_data = JSON.parse(event.data);
        // console.log(json_data.data);
        xtime = json_data.data.x
        ypower = json_data.data.y

        var d = new Date(xtime);
        // d.setSeconds(d.getSeconds() + sec);
        renderStep(d);
        addDataPoint(d, ypower);
        // sec = sec + 2

      });

  }
});
