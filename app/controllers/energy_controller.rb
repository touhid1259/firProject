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

  def get_datewise_printer_data
    begin
      dt = Time.parse(params[:date]).to_date
      etm = Time.parse(params[:end_time])
      stm = etm - 1.hour
      if(dt > Time.now.to_date)
        @printer_data = []

      else
        @printer_data = Energy.consumption_on(dt, stm, etm)
        @printer_data = @printer_data.collect do |item|
          {
            x: "#{item.date} " + "#{item.time.strftime('%H:%M:%S')}",
            y: item.power,
            group: 1
          }

        end

      end

    rescue Exception => ex
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      @printer_data = []

    end

    respond_to do |format|
      format.js {}
    end
  end

end
