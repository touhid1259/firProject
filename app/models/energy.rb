class Energy < ActiveRecord::Base
  self.table_name = 'printer.energy'
  scope :consumption_on, -> (start_time, end_time) {where("datetime >= ? and datetime < ?", start_time, end_time)}
end
