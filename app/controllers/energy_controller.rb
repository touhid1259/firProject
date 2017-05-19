class EnergyController < ApplicationController
  respond_to :html, :xml, :json, :js
  include ActionController::Live
  # LOWER_UPPER_BOUNDS = ClusterConfid.all


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
    graphData = EnergyClass.last(18)
    group_track = 1
    overlay_array = []
    mergedGraphData = []
    index = 0
    index_2 = 0
    # printer_status_data = {}
    # energy_cluster_ids = {}
    # start_datetime = graphData.first.datetime
    # end_datetime = graphData.last.datetime
    # Status.status_of(start_datetime, end_datetime).collect do |item|
    #   printer_status_data[item.timestamp] = item.printer_status
    # end

    # EnergyClass.get_cluster_ids(start_datetime, end_datetime).collect do |item|
    #   energy_cluster_ids[item.datetime] = item.cluster_id
    # end

    track_cluster_id = graphData.first.cluster_id

    graphData = graphData.each do |item|
      if item.cluster_id != track_cluster_id
        group_track = group_track + 1
        track_cluster_id = item.cluster_id
      end

      overlay_array[index] = {
        x: "#{item.datetime.strftime("%F %H:%M:%S")}",
        y: item.power,
        cls_id: item.cluster_id > 6  ? "cls_id_greater_than_6" : "cls_id_" + item.cluster_id.to_s,
        group: group_track # Groups 1, 2, 3 and so on
      }

      con = Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state_category]]
      ash_colored_stream = {
        # x: "#{item.date} " + "#{(item.time - 56.minutes - 7.seconds).strftime('%H:%M:%S')}",
        x: "#{item.datetime.strftime("%F %H:%M:%S")}",
        y: item.power,
        cls_id: item.cluster_id > 6  ? "cls_id_greater_than_6" : "cls_id_" + item.cluster_id.to_s,
        label: {
          content: "#{con ? con : ' '}",
          className: item.cluster_id > 6 ? "lb_cls_id_greater_than_6" : "lb_cls_id_" + item.cluster_id.to_s,
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
        EnergyClass.uncached do
          item = EnergyClass.last
          sleep 0.5
          con = Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state_category]]

          if(last_data_time != item.datetime)
            sse.write({
                data: {
                  x: "#{item.datetime.strftime("%F %H:%M:%S")}",
                  y: item.power,
                  cls_id: item.cluster_id > 6  ? "cls_id_greater_than_6" : "cls_id_" + item.cluster_id.to_s,
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
        puts "here"
        @merged_printer_data = []

      else
        end_datetime = Time.zone.parse("#{params[:date]} " + params[:end_time]) # its in UTC time zone. datetime in database is in UTC format although the date shows the current time of aachen.
        start_datetime = end_datetime - 1.hour
        printer_data = EnergyClass.consumption_on(start_datetime, end_datetime)
        # printer_status_data = {}
        # energy_cluster_ids = {}
        # Status.status_of(start_datetime, end_datetime).collect{|item| printer_status_data[item.timestamp] = item.printer_status}

        # EnergyClass.get_cluster_ids(start_datetime, end_datetime).collect do |item|
        #   energy_cluster_ids[item.datetime] = item.cluster_id
        # end

        track_cluster_id = printer_data.empty? ? nil : printer_data.first.cluster_id

        overlay_array = []
        @merged_printer_data = []
        index = 0
        index_2 = 0
        @group_track = 1

        printer_data = printer_data.each do |item|
          if item.cluster_id != track_cluster_id
            @group_track = @group_track + 1
            track_cluster_id = item.cluster_id
          end

          overlay_array[index] = {
            x: "#{item.datetime.strftime("%F %H:%M:%S")}",
            y: item.power,
            cls_id: item.cluster_id > 6  ? "cls_id_greater_than_6" : "cls_id_" + item.cluster_id.to_s,
            group: @group_track # Groups 1, 2, 3 and so on
          }

          con = Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state_category]]

          ash_colored_stream = {
            x: "#{item.datetime.strftime("%F %H:%M:%S")}",
            y: item.power,
            cls_id: item.cluster_id > 6  ? "cls_id_greater_than_6" : "cls_id_" + item.cluster_id.to_s,
            label: {
              content: "#{con ? con : ' '}",
              className: item.cluster_id > 6 ? "lb_cls_id_greater_than_6" : "lb_cls_id_" + item.cluster_id.to_s,
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

  def googleGraph_printer_energy_data
    graphData = EnergyClass.last(10)
    # printer_status_data = {}
    # cluster_ids = {}
    # start_datetime = graphData.first.datetime
    # end_datetime = graphData.last.datetime
    # Status.status_of(start_datetime, end_datetime).collect do |item|
    #   printer_status_data[item.timestamp] = item.printer_status
    # end

    # EnergyClass.get_cluster_ids(start_datetime, end_datetime).collect do |item|
    #   cluster_ids[item.datetime] = item.cluster_id
    # end

    gon.graphData = graphData.collect{ |item|
      [
        item.datetime.strftime("%H:%M:%S"),
        item.power,
        "color: #{EnergyClass::COLOR_CODES['cluster_' + item.cluster_id.to_s]}",
        Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state_category]]
      ]
    }
  end

  def googleGraph_continuous_printer_energy_data
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, event: 'time')
    begin

      last_data_time = -1
      loop do
        EnergyClass.uncached do
          item = EnergyClass.last
          sleep 0.5
          # printer_status_data = Status.where(timestamp: item.datetime).take
          label_text = Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state_category]]
          # cluster_id = EnergyClass.where(datetime: item.datetime).take
          cluster_color = EnergyClass::COLOR_CODES['cluster_' + item.cluster_id.to_s]

          if(last_data_time != item.datetime)
            sse.write({
                data: {
                  x: "#{item.datetime.strftime("%H:%M:%S")}",
                  y: item.power,
                  style: "color: #{cluster_color}",
                  label: label_text
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

  def printer_energy_prediction
    energy_data = EnergyClass.last(21)
    predicted_energy_data = []
    lower_bounds = []
    upper_bounds = []
    index = 0
    multiple_predicted_energy_data = Prediction.where(datetime: energy_data.collect{|item| item.datetime})
    energy_data = energy_data.collect do |item|
      predicted = multiple_predicted_energy_data.select{|item_2| item_2.datetime == item.datetime }[0]

      # here we are using the cluster value of previous actual data and state value of predicted data for cluster_confid
      lower_upper_bound = ClusterConfid.all.select{|item_3| item_3.cluster_Id == item.cluster_id && item_3.state == predicted.state}[0]
      predicted_energy_data[index] = {
        x: "#{predicted.pred_time.strftime("%F %H:%M:%S")}",
        y: predicted.power,
        label: {
          content: "#{Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[predicted.state]]}",
          className: "lb_predicted",
          xOffset: -7,
          yOffset: -10
        },
        group: 0
      }

      lower_bounds[index] = {
        x: "#{predicted.pred_time.strftime("%F %H:%M:%S")}",
        y: lower_upper_bound.confid_low,
        group: 2
      }

      upper_bounds[index] = {
        x: "#{predicted.pred_time.strftime("%F %H:%M:%S")}",
        y: lower_upper_bound.confid_up,
        group: 3
      }

      index += 1

      next if index == 1

      {
        x: "#{item.datetime.strftime("%F %H:%M:%S")}",
        y: item.power,
        label: {
          content: "#{Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state_category]]}",
          className: "lb_actual",
          xOffset: -7,
          yOffset: -10
        },
        group: 1
      }
    end

    gon.energy_data = (predicted_energy_data + lower_bounds + upper_bounds + energy_data).compact

  end

  def continuous_printer_energy_prediction
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, event: 'time')
    begin

      last_data_time = -1
      loop do
        EnergyClass.uncached do
          item = EnergyClass.last
          sleep 0.5
          pred_item = Prediction.where(datetime: item.datetime)[0]
          lower_upper_bound = ClusterConfid.all.select{|item_3| item_3.cluster_Id == item.cluster_id && item_3.state == pred_item.state}[0]
          con = Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state_category]]
          pred_con = Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[pred_item.state]]

          if(last_data_time != item.datetime)
            sse.write({
                data: {
                  actual: {
                    x: "#{item.datetime.strftime("%F %H:%M:%S")}",
                    y: item.power,
                    label: {
                      content: "#{con ? con : ' '}"
                    },
                    group: 1
                  },
                  predicted: {
                    x: "#{pred_item.pred_time.strftime("%F %H:%M:%S")}",
                    y: pred_item.power,
                    label: {
                      content: "#{pred_con ? pred_con : ' '}"
                    },
                    group: 0
                  },
                  lower: {
                    x: "#{pred_item.pred_time.strftime("%F %H:%M:%S")}",
                    y: lower_upper_bound.confid_low,
                    group: 2
                  },
                  upper: {
                    x: "#{pred_item.pred_time.strftime("%F %H:%M:%S")}",
                    y: lower_upper_bound.confid_up,
                    group: 3
                  }
              }
            })
          end
          last_data_time = item.datetime
          sleep 0.2
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

  def ten_sec_prediction_index
  end

  def get_ten_sec_prediction
    begin
      sl_time = Time.parse(params[:selected_time])
      if(sl_time > Time.now)
        puts "inside if"
        @merged_printer_data = []

      else
        sl_time = Time.zone.parse(params[:selected_time]) # for the correction of the query, we are using the utc timezone as the time in db is in utc
        lower_bound_data = []
        upper_bound_data = []
        ind = 0
        start_datetime = sl_time - 5.seconds
        end_datetime = sl_time + 10.seconds
        actual_printer_data = EnergyClass.consumption_on(start_datetime, end_datetime)
        predicted_energy_data = Prediction.where(datetime: sl_time)
        data_for_calculating_cluster = actual_printer_data.select{|item| item.datetime == sl_time}[0]

        # here we are using the cluster value of previous actual data and state value of current predicted data for cluster_confid
        lower_upper_bound = ClusterConfid.all.select{|item_3| item_3.cluster_Id == data_for_calculating_cluster.cluster_id && item_3.state == predicted_energy_data[0].state}[0]


        predicted_data = predicted_energy_data.collect.with_index do |item, index|
          if index > 0
            # here we are using the cluster value of previous predicted data and state value of current predicted data for cluster_confid
            lower_upper_bound = ClusterConfid.all.select{|item_3| item_3.cluster_Id == data_for_calculating_cluster.cluster && item_3.state == item.state}[0]
          end

          lower_bound_data[ind] = {
            x: "#{item.pred_time.strftime("%F %H:%M:%S")}",
            y: lower_upper_bound.confid_low,
            group: 2
          }

          upper_bound_data[ind] = {
            x: "#{item.pred_time.strftime("%F %H:%M:%S")}",
            y: lower_upper_bound.confid_up,
            group: 3
          }

          data_for_calculating_cluster = item
          ind += 1

          {
            x: "#{item.pred_time.strftime("%F %H:%M:%S")}",
            y: item.power,
            label: {
              content: "#{Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state]]}",
              className: "lb_predicted",
              xOffset: -7,
              yOffset: -10
            },
            group: 0
          }
        end

        actual_data = actual_printer_data.collect do |item|
          if item.datetime == sl_time
            predicted_data << {
                x: "#{item.datetime.strftime("%F %H:%M:%S")}",
                y: item.power,
                group: 0
            }
          end

          {
              x: "#{item.datetime.strftime("%F %H:%M:%S")}",
              y: item.power,
              label: {
                content: "#{Status::PRINTER_STATUS[Status::PRINTER_STATUS_KEYS[item.state_category]]}",
                className: "lb_actual",
                xOffset: -7,
                yOffset: -10
              },
              group: 1
          }

        end

        @merged_printer_data = (actual_data + predicted_data + lower_bound_data + upper_bound_data).compact

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
