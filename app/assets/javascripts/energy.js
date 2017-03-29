$(document).on("turbolinks:load", function() {
  if(window.location.pathname == '/energy')
  {
    // Weather update code start
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
    // Weather update code end

    // little tweaks code start
      $('.fact').on('click', function(){
        $('.choose-machine').dialog();
      });

      $('.printer-link').on('click', function(){
        $('#machineries-modal').modal('hide');
        window.location.href = "/energy/printer";
      });
    // little tweaks code end

    // Google charts code start
      google.charts.load("current", {packages:["corechart"]});
      google.charts.setOnLoadCallback(drawChartActualEnergy);
      google.charts.setOnLoadCallback(drawChartPlannedEnergy);
      google.charts.setOnLoadCallback(drawPriceTrend);
      google.charts.setOnLoadCallback(drawTradedEnergy);

      function drawChartActualEnergy() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Time of Day');
        data.addColumn('number', 'Actual Production');

        data.addRows(gon.actual_energy);

        var options = {
          title: "Actual Energy Production in recent 5 hours",
          hAxis: {
            title: "Time of Day"
          },
          animation:{
            duration: 1000,
            easing: 'out',
            startup: true
          },
          legend: 'none'
        };

        var chart = new google.visualization.ColumnChart(document.getElementById('actual_energy'));
        chart.draw(data, options);
      }

      function drawChartPlannedEnergy() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Time of Day');
        data.addColumn('number', 'Expected Production');
        data.addColumn({type: 'string', role: 'style' });

        data.addRows(gon.planned_energy);

        var options = {
          title: "Expected Energy Production in recent 5 hours",
          hAxis: {
            title: "Time of Day"
          },
          animation:{
            duration: 1000,
            easing: 'out',
            startup: true
          },
          legend: 'none'
        };

        var chart = new google.visualization.ColumnChart(document.getElementById('planned_energy'));
        chart.draw(data, options);
      }

      function drawPriceTrend() {
        var window_width = $(window).width();
        var data = google.visualization.arrayToDataTable(gon.energy_price_trend_data);
        var options = {
          title: 'Predicted Energy Price Trends in recent 5 hours',
          vAxis: {title: 'Price (euro)'},
          hAxis: {title: 'Hours of the Day'},
          seriesType: 'bars',
          series: {4: {type: 'line'}},
          height: window_width < 544 ? 280 : 400,
          animation:{
            duration: 1000,
            easing: 'out',
            startup: true
          },
          legend: {
            position: window_width < 544 ? 'bottom' : 'right'
          }
        };

        var chart = new google.visualization.ComboChart(document.getElementById('energy_price_trend'));
        chart.draw(data, options);
      }

      function drawTradedEnergy(){
        var window_width = $(window).width();
        var data = google.visualization.arrayToDataTable(gon.traded_energy_data);

        var options = {
          title: "Last Hour's Traded Energy in MWh",
          height: window_width < 544 ? 280 : 400,
          animation:{
            duration: 1000,
            easing: 'out',
            startup: true
          },
          legend:{
            position: "bottom"
          },
          is3D: true,
        };

        var chart = new google.visualization.PieChart(document.getElementById('traded_energy'));
        chart.draw(data, options);
      }

    // Google charts code end

  }

// /////////////////////////////////////////////////////////////////////////////

  if(window.location.pathname == '/energy/printer')
  {
      var graph2d;
      var dataset; // x and y axis data array for the graph2d
      var groups;

      function drawPrinterGraph(gpitems){
        var container = $(".printer-graph")[0];
        var items = gpitems
        groups = new vis.DataSet();

        for(i = 0; i <= 200; i++ ){
          groups.add({
              id: i,
              content: 'groups',
              className: 'datewise-data'
          });
        }

        for(i = 0; i < gpitems.length ; i++ ){
          if(gpitems[i].group != 0){
            groups.update({
                id: gpitems[i].group,
                content: 'groups',
                className: gpitems[i].cls_id
            });
          }
        }

        dataset = new vis.DataSet(items);
        var options = {
          start: gpitems[0]['x'],
          end: new Date(new Date(gpitems[14]['x']).getTime() + 2000),
          // end: gpitems[4]['x'],
          interpolation: false,
          drawPoints: {
            onRender: function(item, graph2d){
              if(item.group != 0){
                return {
                  style: 'circle',
                  size: 5,
                  className: item.cls_id
                }

              }else {
                return {
                  style: 'circle',
                  size: 4,
                  className: 'datewise-data'
                }

              }
            },
            style: 'circle', // square, circle
            size: 4
          },
          shaded: {
            orientation: 'bottom' // top, bottom
          },
          moveable: false,
          dataAxis: {
            left: {
              title: {
                text: 'Power'
              }
            }
          }
        };

        graph2d = new vis.Graph2d(container, dataset, groups ,options);
        console.log(graph2d.getWindow());
      }

      drawPrinterGraph(gon.graphData);

    // real time functions start ----

      /**
       * Add a new datapoint to the graph
       */
      var group_track = gon.group_track;
      var printer_recent_data = gon.graphData[gon.graphData.length - 1];
      var recent_cls_id = printer_recent_data['cls_id']
      var real_group_track = group_track;

      function addDataPoint(time, power, con, cls_id) {
        // add a new data point to the dataset
        if(real_group_track == 200){
          real_group_track = group_track;
        }

        if(recent_cls_id != cls_id){
          real_group_track = real_group_track + 1
          recent_cls_id = cls_id
          groups.update({
            id: real_group_track,
            content: 'groups',
            className: cls_id
          });
        }

        dataset.add({
          x: time,
          y: power,
          label: {
            content: con,
            className: "lb_" + cls_id,
            xOffset: -7,
            yOffset: -10
          },
          group: 0,
          className: "datewise-data"
        });

        dataset.add({
          x: time,
          y: power,
          group: real_group_track,
          className: cls_id
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
        var xtime = new Date(time.getTime() + 2000);
        var range = graph2d.getWindow();
        var interval = range.end - range.start;

        graph2d.setWindow(xtime - interval, xtime, {animation: true});

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
        con = json_data.data.label.content
        cls_id = json_data.data.cls_id

        var d = new Date(xtime);
        // d.setSeconds(d.getSeconds() + sec);
        renderStep(d);
        addDataPoint(d, ypower, con, cls_id);
        // sec = sec + 2

      });

    // real time functions end ----

    // Datepicker and datewise energy data code start
      $('#st-date').datetimepicker({
        format: 'YYYY-MM-DD'
      });

      $("#load-printer-date-data").on('click', function(){
        var dt = $("#consumption_date").val();
        var etm = $("#select-hour").val();
        $.ajax({
          type: 'POST',
          url: '/energy/printer/consumption_on',
          data: {date: dt, end_time: etm},
          dataType: 'script',
          beforeSend: function(){
            $("#load-printer-date-data").css('display', 'none');
            $("#load-printer-date-data-loader").css('display', 'inline-block');
          },
          complete: function(){
            $("#load-printer-date-data").css('display', 'inline-block');
            $("#load-printer-date-data-loader").css('display', 'none');
          }
        });
      });
    // Datepicker and datewise energy data code end

  }
});
