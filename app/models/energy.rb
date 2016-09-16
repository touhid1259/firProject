class Energy < ActiveRecord::Base
  self.table_name = 'printer.energy'
  scope :consumption_on, -> (dt, stm, etm) {where("date = ? and (time >= ? and time < ? )", dt, stm, etm)}
end
