class ControlController < ApplicationController
	def index
		@tables = ActiveRecord::Base.connection.tables
		graphData = TbWeidmuellerHf2.where(MaschinenID: "HF_Laser").select("Datum, Zeit, MaschinenID, [Spannung(Durchschnitt) in 0.01V]").limit(1000)
		gon.graphData = graphData.collect do |item|
			{
				x: "#{item.Datum} " + "#{item.Zeit.strftime('%H:%M:%S')}",
				y: item["Spannung(Durchschnitt) in 0.01V"]
			}
		end
	end
end
