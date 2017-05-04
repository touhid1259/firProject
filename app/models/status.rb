class Status < ActiveRecord::Base
  self.table_name = 'printer.status'
  PRINTER_STATUS = {
    "NoState" => "",
    "Bereit" => "🅱",
    "Wärmt auf..." => "🆆",
    "Drucken..." => "🅳",
    "Energiesparmodus" => "🅴",
    "Offline" => "🅾",
    "Fehler" => "🅵",
    "Alarm" => "🅰",
    "Kartusche bald leer" => "🅴" #"🅺",
    # "WÃ¤rmt auf..." => "🆆"
  }

  # This Constant is used because there is a integer value for each state.
  # i.e. 1 => "Bereit" and so on. So, for accommodating the interger
  # we are using this below constant
  PRINTER_STATUS_KEYS = PRINTER_STATUS.keys

  scope :status_of, -> (start_time, end_time) {where("timestamp >= ? and timestamp <= ?", start_time, end_time)}
end
