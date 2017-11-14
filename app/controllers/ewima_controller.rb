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

    puts dataForGraph.count

    gon.dataToVisualizeOne = dataForGraph[0..21]
    gon.dataToVisualizeTwo = dataForGraph[22..43]

  end
end
