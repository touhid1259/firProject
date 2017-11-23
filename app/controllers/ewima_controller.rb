class EwimaController < ApplicationController
  def select_your_preference
    dataForGraph = []
    velData = PaperOne.all
    preferred_velocities = velData + velData.shuffle + velData.shuffle + velData.shuffle

    timeLineValue = Time.parse(Date.today.to_s + " 08:00:00")

    preferred_velocities.each_with_index do |item, index|

      timeLineValue = Time.parse(Date.today.to_s + " 08:00:00") if (timeLineValue > Time.parse(Date.today.to_s + " 15:45:00"))

      dataForGraph <<
      {
        x: timeLineValue.to_s,
        y: item.v1,
        group: 0
      }

      dataForGraph <<
      {
        x: timeLineValue.to_s,
        y: item.v2,
        group: 1
      }

      timeLineValue = timeLineValue + 15.minutes

    end

    gon.dataToVisualizeOne = dataForGraph[0..63]
    gon.dataToVisualizeTwo = dataForGraph[64..127]
    gon.dataToVisualizeThree = dataForGraph[128..191]
    gon.dataToVisualizeFour = dataForGraph[192..255]

  end

  def summary_view
    dataForGraph = [[], [], []]
    optimalConsumptionPriceData = PaperTwo.all

    timeLineValue = Time.parse(Date.today.to_s + " 08:00:00")

    optimalConsumptionPriceData.each do |item|

          dataForGraph[0] <<
          {
            x: timeLineValue.to_s,
            y: item.v1,
            group: 0
          }

          dataForGraph[0] <<
          {
            x: timeLineValue.to_s,
            y: item.v2,
            group: 1
          }

          dataForGraph[1] <<
          {
            x: timeLineValue.to_s,
            y: item.power,
            group: 2
          }

          dataForGraph[2] <<
          {
            x: timeLineValue.to_s,
            y: item.energyprice,
            group: 2
          }

      timeLineValue = timeLineValue + 15.minutes

    end

    gon.optimalGraphData = dataForGraph[0]
    gon.energyConsumptionData = dataForGraph[1]
    gon.energyPriceData = dataForGraph[2]

  end

end
