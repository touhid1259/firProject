class EwimaController < ApplicationController
  def select_your_preference
    dataForGraph = []
    preferred_velocities = PaperOne.all
    timeLineValue = 8

    preferred_velocities.each_with_index do |item, index|
      timeLineValue = 8 if timeLineValue > 18
      break if index > 21
      dataForGraph <<
      {
        x: Date.today.to_s + (timeLineValue > 9 ? " #{timeLineValue}:00:00" : " 0#{timeLineValue}:00:00"),
        y: item.v1,
        group: 0
      }

      dataForGraph <<
      {
        x: Date.today.to_s + (timeLineValue > 9 ? " #{timeLineValue}:00:00" : " 0#{timeLineValue}:00:00"),
        y: item.v2,
        group: 1
      }

      timeLineValue = timeLineValue + 1

    end

    gon.dataToVisualizeOne = dataForGraph[0..21]
    gon.dataToVisualizeTwo = dataForGraph[22..43]

  end

  def summary_view
    dataForGraph = [[], [], []]
    optimalGraphData = PaperOne.all
    consumptionAndPriceData = PaperTwo.all

    timeLineValue = 8

    optimalGraphData[21..31].each do |item|
      timeLineValue = 8 if timeLineValue > 18

      dataForGraph[0] <<
      {
        x: Date.today.to_s + (timeLineValue > 9 ? " #{timeLineValue}:00:00" : " 0#{timeLineValue}:00:00"),
        y: item.v1,
        group: 0
      }

      dataForGraph[0] <<
      {
        x: Date.today.to_s + (timeLineValue > 9 ? " #{timeLineValue}:00:00" : " 0#{timeLineValue}:00:00"),
        y: item.v2,
        group: 1
      }

      timeLineValue = timeLineValue + 1

    end

    consumptionAndPriceData.each_with_index do |item, index|
      timeLineValue = 8 if timeLineValue > 18
      break if index > 10
      dataForGraph[1] <<
      {
        x: Date.today.to_s + (timeLineValue > 9 ? " #{timeLineValue}:00:00" : " 0#{timeLineValue}:00:00"),
        y: item.power,
        group: 0
      }

      dataForGraph[2] <<
      {
        x: Date.today.to_s + (timeLineValue > 9 ? " #{timeLineValue}:00:00" : " 0#{timeLineValue}:00:00"),
        y: item.energyprice,
        group: 0
      }

      timeLineValue = timeLineValue + 1
    end

    gon.optimalGraphData = dataForGraph[0]
    gon.energyConsumptionData = dataForGraph[1]
    gon.energyPriceData = dataForGraph[2]

  end
end
