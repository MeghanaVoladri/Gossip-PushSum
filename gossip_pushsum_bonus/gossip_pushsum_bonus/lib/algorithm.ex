defmodule Algorithm do
  def startPushSum(nodes, startTime, errorNodes) do
    startNode = Enum.random(nodes)
    GenServer.cast(startNode, {:pushsum, 0, 0, startTime, length(nodes), errorNodes})
  end

  def sendPushSum(new_node, this_s, this_w, startTime, length, errorNodes) do
    GenServer.cast(new_node, {:pushsum, this_s, this_w, startTime, length, errorNodes})
  end

  def startGossip(nodes, startTime, errorNodes) do
    startNode = Enum.random(nodes)
    GossipPushSum.updatecount(startNode, startTime, length(nodes), errorNodes)
    rumour(startNode, startTime, length(nodes), errorNodes)
  end

  def rumour(startNode, startTime, length, errorNodes) do
    count = GossipPushSum.getcount(startNode)

    cond do
      count < 10 ->
        adjacentList = GossipPushSum.getAdjacentList(startNode)
        newNode = Enum.random(adjacentList)
        Task.start(Algorithm, :new_rumour, [newNode, startTime, length, errorNodes])
        rumour(newNode, startTime, length, errorNodes)

      true ->
        Process.exit(startNode, :normal)
    end

    rumour(startNode, startTime, length, errorNodes)
  end

  def new_rumour(newNode, startTime, length, errorNodes) do
    GossipPushSum.updatecount(newNode, startTime, length, errorNodes)
    rumour(newNode, startTime, length, errorNodes)
  end
end
