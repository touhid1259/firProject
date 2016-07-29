class EnergyController < ApplicationController
  def index

  end

  def printer_energy_data
    graphData = Energy.last(50)
    gon.graphData = graphData.collect do |item|
      {
        x: "#{item.date} " + "#{item.time.strftime('%H:%M:%S')}",
        y: item.power
      }
    end
  end

end
