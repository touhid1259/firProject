class EnergyController < ApplicationController
  include ActionController::Live


  def index
    timestamp = []
    # last 5 hour's energy production
    gon.actual_energy = ActualGeneration.where(country: "DE").last(5).collect{ |item|
      timestamp.push(item.timestamp)
      [item.timestamp.in_time_zone("CET").strftime("%H:%M"), item.actual_energy]
    }

    gon.planned_energy = PlannedGeneration.where({country: "DE", timestamp: timestamp}).collect{|item|
      [item.timestamp.in_time_zone("CET").strftime("%H:%M"), item.expected_energy, "gold"]
    }

    gon.energy_price_trend = [
      [
       "Hours of the Day", "1st Quarter", "2nd Quarter",
       "3rd Quarter", "4th Quarter", "Average"
      ]
    ]
    price_data = EnergyPriceDayAhead.where("date <= ?", Time.now).last(200).reject{|item|
      item.date == Time.now.strftime("%Y-%m-%d") and item.time.to_i >= Time.now.strftime("%H").to_i
    }.last(20)

    (0..16).step(4) do |i|
      trend_data = [(price_data[i].time.to_i + 1).ordinalize, price_data[i].price, price_data[i+1].price,
                    price_data[i+2].price, price_data[i+3].price,
                    (price_data[i].price + price_data[i+1].price + price_data[i+2].price + price_data[i+3].price)/4]

      gon.energy_price_trend.push(trend_data)
    end

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
        overlay_array = []
        index = 0
        @group_track = 1
        increased = true

        @printer_data = @printer_data.collect do |item|
          if item.power > 50
            overlay_array[index] = {
              x: "#{item.date} " + "#{item.time.strftime('%H:%M:%S')}",
              y: item.power,
              group: @group_track # Groups 1, 2, 3 and so on
            }
            index = index + 1
            increased = false

          else
             increased ? @group_track : @group_track = @group_track + 1
             increased = true

          end

          {
            x: "#{item.date} " + "#{item.time.strftime('%H:%M:%S')}",
            y: item.power,
            group: 0
          }

        end

        @printer_data = @printer_data + overlay_array


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
