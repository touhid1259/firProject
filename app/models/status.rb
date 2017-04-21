class Status < ActiveRecord::Base
  self.table_name = 'printer.status'
  PRINTER_STATUS = {
    "Alarm" => "🅰",
    "Drucken..." => "🅳",
    "WÃ¤rmt auf..." => "🆆",
    "Energiesparmodus" => "🅴",
    "Bereit" => "🅱",
    "Offline" => "🅾",
    "Fehler" => "🅵",
    "Kartusche bald leer" => "🅴",#"🅺",
    "Wärmt auf..." => "🆆"
  }

  scope :status_of, -> (start_time, end_time) {where("timestamp >= ? and timestamp <= ?", start_time, end_time)}
end
