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

  def rough_planning
    tunnelData = RoughPlanning.all
    dataForGraph = [[],[],[],[],[]]
    timeLineValue = Time.now
    tunnelData.collect do |item|
      (1..5).each do |i|
        dataForGraph[i - 1] <<
        {
          x: timeLineValue.to_s,
          y: item["tunnel#{i}"],
          group: 0
        }
      end

      timeLineValue = timeLineValue + 6.hours

    end

    gon.dataForTunnelOne = dataForGraph[0]
    gon.dataForTunnelTwo = dataForGraph[1]
    gon.dataForTunnelThree = dataForGraph[2]
    gon.dataForTunnelFour = dataForGraph[3]
    gon.dataForTunnelFive = dataForGraph[4]

  end

  def detailed_planning
    tunnelData = [DetailedPlanningOne.all, DetailedPlanningTwo.all]
    dataForGraph = [ [ [], [], [], [], [] ], [ [], [], [], [], [] ] ]
    timeLineValue = Time.now
    timeToStore = timeLineValue

    2.times.each do |tm|
      tunnelData[tm].collect do |item|
        (1..5).each do |i|
          dataForGraph[tm][i - 1] <<
          {
            x: timeLineValue.to_s,
            y: item["tunnel#{i}"],
            group: 0
          }
        end

        timeLineValue = timeLineValue + 1.hour

      end
      timeLineValue = timeToStore

    end

    detailedDataOneForTunnel = [ dataForGraph[0][0], dataForGraph[0][1], dataForGraph[0][2],
                                    dataForGraph[0][3], dataForGraph[0][4] ]

    detailedDataTwoForTunnel = [ dataForGraph[1][0], dataForGraph[1][1], dataForGraph[1][2],
                                    dataForGraph[1][3], dataForGraph[1][4] ]

    gon.detailedPlanningData = [ detailedDataOneForTunnel, detailedDataTwoForTunnel ]

  end

  def planning_summary
    @access = true
    if params[:preference] == "select1"

      tunnelData = DetailedPlanningOne.all
      statisticsData = StatisticsOne.all
      energyConsumptionData = EnergyConsumptionOne.all
      energyPriceData = EnergyPrice.all

      dataForTunnelGraph = [[],[],[],[],[]]
      dataForConsPrice = [[], []]
      dataForStats = []
      timeLineValue = Time.now
      timeToStore = timeLineValue

      tunnelData.collect.with_index do |item, index|
        (1..5).each do |i|
          dataForTunnelGraph[i - 1] <<
          {
            x: timeLineValue.to_s,
            y: item["tunnel#{i}"],
            group: 0
          }
        end

        (1..2).each do |i|
          dataToShow = (i == 1 ? energyConsumptionData[index][:energyconsumption] : energyPriceData[index][:energyprice] )
          dataForConsPrice[i - 1] <<
          {
            x: timeLineValue.to_s,
            y: dataToShow,
            group: 0
          }
        end

        timeLineValue = timeLineValue + 1.hour
      end

      gon.preferredData = dataForTunnelGraph
      gon.consumptionData = dataForConsPrice[0]
      gon.priceData = dataForConsPrice[1]

    elsif params[:preference] == "select2"


    else
      @access = false
    end

  end

end
