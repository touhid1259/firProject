class EnergyController < ApplicationController
  include ActionController::Live


  def index

  end

  def printer_energy_data
    graphData = Energy.last(50)
    gon.graphData = graphData.collect do |item|
      {
        x: "#{item.date} " + "#{(item.time - 57.minutes + 10.seconds).strftime('%H:%M:%S')}",
        y: item.power
      }
    end
  end

  def continuous_printer_energy_data
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, event: 'time')
    begin
      loop do
        # puts request.path
        # if(request.path == '/energy/printer/continuous')
        #   sse.close
        #   break
        # end
        Energy.uncached do
          a = Energy.last
          sse.write({ :data => a })
          sleep 1
        end

      end

    rescue Exception => e
      puts 'its a exception'
      logger.error e.backtrace.join("\n")
      sse.close

    ensure
      sse.close

    end
    render nothing: true
    
  end

end
