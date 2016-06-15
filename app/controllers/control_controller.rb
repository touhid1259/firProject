class ControlController < ApplicationController
	def index
		@tables = ActiveRecord::Base.connection.tables
		gon.graphData = TbWeidmuellerHf2.where(MaschinenID: "HF_Laser").select("Datum, Zeit, MaschinenID, [Spannung(Durchschnitt) in 0.01V]").limit(10)
	end
end
