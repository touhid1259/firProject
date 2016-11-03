class ControlController < ApplicationController
	def index
		# @tables = DfaDbConnection.connection.tables
		graphData = TbWeidmuellerHf2.limit(5000)
		gon.stormData = []
		gon.spannungData = graphData.collect do |item|
			gon.stormData << {
				x: "#{item.Datum} " + "#{item.Zeit.strftime('%H:%M:%S')}",
				y: item["Strom_Durchschnitt_in_0_001A"],
				group: item.MaschinenID,
				label: {
					content: item["Strom_Durchschnitt_in_0_001A"],
					className: "point-label",
					xOffset: -10,
					yOffset: -10
				}
			}

			{
				x: "#{item.Datum} " + "#{item.Zeit.strftime('%H:%M:%S')}",
				y: item["Spannung_Durchschnitt_in_0_01V"],
				group: item.MaschinenID,
				label: {
					content: item["Spannung_Durchschnitt_in_0_01V"],
					className: "point-label",
					xOffset: -10,
					yOffset: -10
				}
			}
		end
	end
end
