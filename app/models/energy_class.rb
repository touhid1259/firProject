class EnergyClass < ActiveRecord::Base
  self.table_name = 'printer.energy_class'
  scope :get_cluster_ids, -> (start_time, end_time) {where("datetime >= ? and datetime <= ?", start_time, end_time)}

  COLOR_CODES = {
    'cluster_1' => '#006dff',
    'cluster_2' => '#01a737',
    'cluster_3' => '#f92b71',
    'cluster_4' => '#dcc600',
    'cluster_5' => '#a776ff',
    'cluster_6' => '#f97421',
    'cluster_7' => '#795548',
    'cluster_8' => '#de2afd'
  }

end
