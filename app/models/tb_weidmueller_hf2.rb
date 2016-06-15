class TbWeidmuellerHf2 < ActiveRecord::Base
	self.table_name = 'dbo.tbWeidmuellerHF2'
	self.primary_key = :id # there is no 'id' column in the table. It is just for solving one error(to_json error).  
end
