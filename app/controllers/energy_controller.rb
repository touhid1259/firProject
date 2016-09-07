class EnergyController < ApplicationController
  include ActionController::Live


  def index

  end

  def printer_energy_data
    graphData = Energy.last(50)
    # graphData = [
    #   {'date': Time.now.strftime('%F') , 'time': Time.now, 'power': 14},
    #   {'date': Time.now.strftime('%F') , 'time': Time.now + 2.seconds, 'power': 15},
    #   {'date': Time.now.strftime('%F') , 'time': Time.now + 4.seconds, 'power': 18},
    #   {'date': Time.now.strftime('%F') , 'time': Time.now + 6.seconds, 'power': 17},
    #   {'date': Time.now.strftime('%F') , 'time': Time.now + 8.seconds, 'power': 14}
    # ]
    gon.graphData = graphData.collect do |item|
      {
        x: "#{item.date} " + "#{(item.time - 56.minutes - 7.seconds).strftime('%H:%M:%S')}",
        y: item.power,
        group: 0
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
          # item = {'date': Time.now.strftime('%F') , 'time': Time.now, 'power': rand(14..20)}
          if(last_id != item.id)
            sse.write({
                data: {
                  x: "#{item.date} " + "#{(item.time - 56.minutes - 7.seconds).strftime('%H:%M:%S')}",
                  y: item.power,
                  group: 0
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
