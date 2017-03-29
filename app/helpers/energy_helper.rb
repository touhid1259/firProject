module EnergyHelper
  def return_json(dt)
    dt.to_json.html_safe
  end
end
