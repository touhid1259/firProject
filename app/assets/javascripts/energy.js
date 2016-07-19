if(window.location.pathname == '/energy')
{
  $(document).ready(function() {
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
  });
}