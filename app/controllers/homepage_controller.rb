class HomepageController < ApplicationController
	include ActionController::Live

	def index
	end

	def demo_coding
		graphData = Energy.last(18)
		graphData = graphData.collect do |item|
			{
				x: "#{item.datetime.strftime("%F %H:%M:%S")}",
				y: item.power,
				group: 0
			}

		end

		gon.graphData = graphData
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
					if(last_data_time != item.datetime)
						sse.write({
								data: {
									x: "#{item.datetime.strftime("%F %H:%M:%S")}",
									y: item.power,
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

end
