defmodule Algorithm do
  def startPushSum(nodes, startTime) do
    startNode = Enum.random(nodes)
    GenServer.cast(startNode, {:pushsum, 0, 0, startTime, length(nodes)})
  end

  def sendPushSum(new_node, this_s, this_w, startTime, length) do
    GenServer.cast(new_node, {:pushsum, this_s, this_w, startTime, length})
  end

  def startGossip(nodes, startTime) do
    startNode = Enum.random(nodes)
    GossipPushSum.updatecount(startNode, startTime, length(nodes))
    rumour(startNode, startTime, length(nodes))
  end

  def rumour(startNode, startTime, length) do
    count = GossipPushSum.getcount(startNode)

    cond do
      count < 10 ->
        adjacentList = GossipPushSum.getAdjacentList(startNode)
        newNode = Enum.random(adjacentList)
        Task.start(Algorithm, :new_rumour, [newNode, startTime, length])
        rumour(newNode, startTime, length)

      true ->
        Process.exit(startNode, :normal)
    end

    rumour(startNode, startTime, length)
  end

  def new_rumour(newNode, startTime, length) do
    GossipPushSum.updatecount(newNode, startTime, length)
    rumour(newNode, startTime, length)
  end
end
