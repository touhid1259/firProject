class TbMaschinenZustand < ActiveRecord::Base
	self.table_name = 'dbo.tbMaschinenZustand'
	self.primary_key = 'MZ_ID'
end
