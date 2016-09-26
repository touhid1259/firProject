class TbWeidmuellerHf2 < DfaDbConnection
	# self.table_name = 'dbo.tbweidmuellerhf2'
	# self.primary_key = :id # there is no 'id' column in the table. It is just for solving one error(to_json error).
	self.table_name = 'dfa.tbweidmuellerhf2'
	MACHINES = ["HF_Laser", "AbsauganlageLaser", "KuehlungLaser", "MechanikLaser", "Druckluft"]
end
