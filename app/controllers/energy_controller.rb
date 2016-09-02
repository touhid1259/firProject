class EnergyController < ApplicationController
  include ActionController::Live


  def index

  end

  def printer_energy_data
    graphData = Energy.last(50)
    gon.graphData = graphData.collect do |item|
      {
        x: "#{item.date} " + "#{(item.time - 56.minutes - 7.seconds).strftime('%H:%M:%S')}",
        y: item.power
        # group: item.power > 18 ? 1 : 0
      }
    end
  end

  def continuous_printer_energy_data
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, event: 'time')
    begin
      last_id = -1
      loop do
        Energy.uncached do
          item = Energy.last
          if(last_id != item.id)
            sse.write({
                data: {
                  x: "#{item.date} " + "#{(item.time - 56.minutes - 7.seconds).strftime('%H:%M:%S')}",
                  y: item.power
                }
            })
          end
          last_id = item.id
          sleep 1
        end

      end

    rescue Exception => e
      puts "its an exception - #{e.message}"
      logger.error e.backtrace.join("\n")
      sse.close

    ensure
      sse.close

    end
    render nothing: true

  end

end
