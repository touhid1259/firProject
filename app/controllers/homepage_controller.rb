class HomepageController < ApplicationController
	include ActionController::Live

	def index
	end

	def demo_coding
		graphData = Energy.last(10)
		printer_status_data = {}
		start_datetime = graphData.first.datetime
		end_datetime = graphData.last.datetime
		Status.status_of(start_datetime, end_datetime).collect do |item|
			printer_status_data[item.timestamp] = item.printer_status
		end

		gon.graphData = graphData.collect{ |item|
			[
				item.datetime.strftime("%H:%M:%S"),
				item.power,
				item.power > 18 ? "color: green" : "color: blue",
				Status::PRINTER_STATUS[printer_status_data[item.datetime]]
			]
		}
	end

	def demo_continuous_printer_energy_data
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, event: 'time')
    begin

      last_data_time = -1
      loop do
        Energy.uncached do
          item = Energy.last
          sleep 0.5
					printer_status_data = Status.where(timestamp: item.datetime).take
          label_text = printer_status_data.nil? ? nil : Status::PRINTER_STATUS[printer_status_data.printer_status]

          if(last_data_time != item.datetime)
            sse.write({
                data: {
                  x: "#{item.datetime.strftime("%H:%M:%S")}",
                  y: item.power,
									style: item.power > 18 ? "color: green" : "color: blue",
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

end
