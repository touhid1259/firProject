class EnergyClass < ActiveRecord::Base
  self.table_name = 'printer.energy_class'
  scope :get_cluster_ids, -> (start_time, end_time) {where("datetime >= ? and datetime <= ?", start_time, end_time)}
end
