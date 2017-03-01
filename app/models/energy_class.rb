class EnergyClass < ActiveRecord::Base
  self.table_name = 'printer.energy_class'
  scope :getting_cluster_ids, -> (start_time, end_time) {where("datetime >= ? and datetime <= ?", start_time, end_time)}

  CLUSTER_COLOR = {
    1 => "#006dff",
    2 => "#01a737",
    3 => "#f92b71",
    4 => "#dcc600",
    5 => "#a776ff",
    6 => "#f97421",
    7 => "#9b73e2",
    8 => "#de2afd"
  }

end
