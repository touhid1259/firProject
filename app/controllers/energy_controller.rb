class EnergyController < ApplicationController
  respond_to :html, :xml, :json, :js
  include ActionController::Live


  def index
    timestamp = []
    # last 5 hour's energy production Actual vs Planned
    gon.actual_energy = ActualGeneration.where(country: "DE").last(5).collect{ |item|
      timestamp.push(item.timestamp)
      [item.timestamp.in_time_zone("CET").strftime("%H:%M"), item.actual_energy]
    }

    gon.planned_energy = PlannedGeneration.where({country: "DE", timestamp: timestamp}).collect{|item|
      [item.timestamp.in_time_zone("CET").strftime("%H:%M"), item.expected_energy, "gold"]
    }

    # Recent 5 hour's energy price trends
    gon.energy_price_trend_data = [
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

      gon.energy_price_trend_data.push(trend_data)
    end

    # most recent hour's traded energy
    gon.traded_energy_data = [
      ["Quarter", "Amount (in MWh)"],
      ["1st Quarter", price_data[16].amount],
      ["2nd Quarter", price_data[17].amount],
      ["3rd Quarter", price_data[18].amount],
      ["4th Quarter", price_data[19].amount],
    ]

  end

  def printer_energy_data
    graphData = Energy.last(18)
    group_track = 1
    overlay_array = []
    mergedGraphData = []
    index = 0
    index_2 = 0
    printer_status_data = {}
    energy_cluster_ids = {}
    start_datetime = graphData.first.datetime
    end_datetime = graphData.last.datetime
    Status.status_of(start_datetime, end_datetime).collect do |item|
      printer_status_data[item.timestamp] = item.printer_status
    end

    EnergyClass.get_cluster_ids(start_datetime, end_datetime).collect do |item|
      energy_cluster_ids[item.datetime] = item.cluster_id
    end

    track_cluster_id = energy_cluster_ids.first[1]

    graphData = graphData.each do |item|
      if energy_cluster_ids[item.datetime] != track_cluster_id
        group_track = group_track + 1
        track_cluster_id = energy_cluster_ids[item.datetime]
      end

      overlay_array[index] = {
        x: "#{item.datetime.strftime("%F %H:%M:%S")}",
        y: item.power,
        cls_id: "cls_id_" + energy_cluster_ids[item.datetime].to_s,
        group: group_track # Groups 1, 2, 3 and so on
      }

      con = Status::PRINTER_STATUS[printer_status_data[item.datetime]]
      ash_colored_stream = {
        # x: "#{item.date} " + "#{(item.time - 56.minutes - 7.seconds).strftime('%H:%M:%S')}",
        x: "#{item.datetime.strftime("%F %H:%M:%S")}",
        y: item.power,
        cls_id: "cls_id_" + energy_cluster_ids[item.datetime].to_s,
        label: {
          content: "#{con ? con : ' '}",
          className: "lb_cls_id_" + energy_cluster_ids[item.datetime].to_s,
          xOffset: -7,
          yOffset: -10
        },
        group: 0
      }

      mergedGraphData[index_2] = ash_colored_stream
      mergedGraphData[index_2 + 1] = overlay_array[index]
      index = index + 1
      index_2 = index_2 + 2

    end

    gon.group_track = group_track
    gon.graphData = mergedGraphData

  end

  def continuous_printer_energy_data
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, event: 'time')
    begin

      last_data_time = -1
      loop do
        Energy.uncached do
          item = Energy.last
          sleep 0.5
          printer_status_data = Status.where(timestamp: item.datetime).take
          con = printer_status_data.nil? ? nil : Status::PRINTER_STATUS[printer_status_data.printer_status]

          cluster = EnergyClass.where(datetime: item.datetime).take
          cluster_id = cluster.nil? ? nil : cluster.cluster_id

          # item = {'date': Time.now.strftime('%F') , 'time': Time.now, 'power': rand(14..20)}
          if(last_data_time != item.datetime)
            sse.write({
                data: {
                  x: "#{item.datetime.strftime("%F %H:%M:%S")}",
                  y: item.power,
                  cls_id: "cls_id_" + cluster_id.to_s,
                  label: {
                    content: "#{con ? con : ' '}"
                  },
                  group: 0
                }
            })
          end
          last_data_time = item.datetime
          sleep 0.5
        end

      end

    rescue Exception => e
      logger.error "its an exception - #{e.message}"
      logger.error e.backtrace.join("\n")
      sse.close

    ensure
      sse.close

    end
    render nothing: true

  end

  def get_datewise_printer_data
    begin
      date = Time.parse(params[:date]).to_date
      if(date > Time.now.to_date)
        @merged_printer_data = []

      else
        end_datetime = Time.zone.parse("#{params[:date]} " + params[:end_time]) # its in UTC time zone. datetime in database is in UTC format although the date shows the current time of aachen.
        start_datetime = end_datetime - 1.hour
        printer_data = Energy.consumption_on(start_datetime, end_datetime)
        printer_status_data = {}
        energy_cluster_ids = {}
        Status.status_of(start_datetime, end_datetime).collect{|item| printer_status_data[item.timestamp] = item.printer_status}

        EnergyClass.get_cluster_ids(start_datetime, end_datetime).collect do |item|
          energy_cluster_ids[item.datetime] = item.cluster_id
        end

        track_cluster_id = energy_cluster_ids.first[1]

        overlay_array = []
        @merged_printer_data = []
        index = 0
        index_2 = 0
        @group_track = 1

        printer_data = printer_data.each do |item|
          if energy_cluster_ids[item.datetime] != track_cluster_id
            @group_track = @group_track + 1
            track_cluster_id = energy_cluster_ids[item.datetime]
          end

          overlay_array[index] = {
            x: "#{item.datetime.strftime("%F %H:%M:%S")}",
            y: item.power,
            cls_id: "cls_id_" + energy_cluster_ids[item.datetime].to_s,
            group: @group_track # Groups 1, 2, 3 and so on
          }

          con = Status::PRINTER_STATUS[printer_status_data[item.datetime]]

          ash_colored_stream = {
            x: "#{item.datetime.strftime("%F %H:%M:%S")}",
            y: item.power,
            cls_id: "cls_id_" + energy_cluster_ids[item.datetime].to_s,
            label: {
              content: "#{con ? con : ' '}",
              className: "lb_cls_id_" + energy_cluster_ids[item.datetime].to_s,
              xOffset: -7,
              yOffset: -10
            },
            group: 0
          }

          @merged_printer_data[index_2] = ash_colored_stream
          @merged_printer_data[index_2 + 1] = overlay_array[index]
          index_2 = index_2 + 2
          index = index + 1

        end

      end

    rescue Exception => ex
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      @merged_printer_data = []

    end

    respond_to do |format|
      format.js {}
    end

  end

end
