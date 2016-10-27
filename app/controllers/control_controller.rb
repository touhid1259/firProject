class ControlController < ApplicationController
	def index
		# @tables = DfaDbConnection.connection.tables
		graphData = TbWeidmuellerHf2.limit(5000)
		gon.graphData = graphData.collect do |item|
			{
				x: "#{item.Datum} " + "#{item.Zeit.strftime('%H:%M:%S')}",
				y: item["Spannung_Durchschnitt_in_0_01V"],
				group: item.MaschinenID,
				label: {
					content: item["Spannung_Durchschnitt_in_0_01V"],
					className: "point-label",
					xOffset: -10,
					yOffset: -10,
				}
			}
		end
	end
end
