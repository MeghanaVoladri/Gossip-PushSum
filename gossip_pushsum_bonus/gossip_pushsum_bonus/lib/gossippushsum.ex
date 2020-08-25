defmodule GossipPushSum do
  use GenServer

  def start_node() do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [])
    pid
  end

  def init(:ok) do
    {:ok, {0, 0, [], 1}}
  end

  def listRandomNodes(length, list \\ []) do
    if length == 0 do
      list
    else
      (length - 1) |> listRandomNodes([:rand.uniform() |> Float.round(2) | list])
    end
  end

  def isNeighbour(a, b) do
    {a1, a2} = a
    {b1, b2} = b
    dist = :math.pow(:math.pow(b1 - a1, 2) + :math.pow(b2 - a2, 2), 0.5)

    if dist > 0 and dist <= 0.1 do
      true
    else
      false
    end
  end

  def is3DRight(i, length) do
    num = trunc(:math.pow(length, 0.3333334))
    len1 = num * num
    i = rem(i, len1)
    k = rem(i + 1, num)

    if(rem(i + 1, num) == 0) do
      true
    else
      false
    end
  end

  def isRight(i, length) do
    num = trunc(:math.pow(length, 0.3333334))
    len1 = num * num
    i = rem(i, len1)
    k = rem(i + 1, num)

    if(rem(i + 1, num) == 0) do
      true
    else
      false
    end
  end

  def isLeft(i, length) do
    num = trunc(:math.pow(length, 0.3333334))
    len1 = num * num
    i = rem(i, len1)

    if(rem(i, trunc(:math.sqrt(len1))) == 0) do
      true
    else
      false
    end
  end

  def isFront(i, length) do
    len1 = trunc(:math.pow(length, 0.3333334))

    if i < trunc(:math.pow(len1, 2)) do
      true
    else
      false
    end
  end

  def isLast(i, length) do
    len1 = trunc(:math.pow(length, 0.3333334))

    if i + trunc(:math.pow(len1, 2)) >= length do
      true
    else
      false
    end
  end

  def isTop(i, length) do
    num = trunc(:math.pow(length, 0.3333334))
    i = rem(i, num * num)

    if i < num do
      true
    else
      false
    end
  end

  def isBottom(i, length) do
    num = trunc(:math.pow(length, 0.3333334))
    len1 = num * num
    i = rem(i, len1)

    if i >= len1 - trunc(:math.sqrt(len1)) do
      true
    else
      false
    end
  end

  def main(nodes, topology, algorithm, errorNodes) do
    nodes =
      if(topology == "3Dtorus") do
        cuberoot = round(:math.pow(nodes, 0.34))
        nodes = cuberoot * cuberoot * cuberoot
      else
        if(topology == "honeycomb") do
          sqroot = round(:math.pow(nodes, 0.5))
          nodes = sqroot * sqroot
        else
          nodes
        end
      end

    num = createNodes(nodes)
    createTable()

    cond do
      topology == "full" ->
        Enum.each(num, fn x ->
          neighbourList = List.delete(num, x)
          toNeighbourList(x, neighbourList)
        end)

      topology == "line" ->
        first = 0
        last = length(num) - 1

        Enum.each(num, fn x ->
          i = Enum.find_index(num, fn y -> y == x end)
          neighbourList = []

          cond do
            i < first ->
              neighbourList = neighbourList ++ [Enum.at(num, i + 1)]
              toNeighbourList(x, neighbourList)

            i < last && i > first ->
              neighbourList = neighbourList ++ [Enum.at(num, i - 1), Enum.at(num, i + 1)]
              toNeighbourList(x, neighbourList)

            true ->
              neighbourList = neighbourList ++ [Enum.at(num, i - 1)]
              toNeighbourList(x, neighbourList)
          end
        end)

      topology == "3Dtorus" ->
        numNodes = Enum.count(num)

        Enum.each(num, fn k ->
          neighbourList = []
          count = Enum.find_index(num, fn x -> x == k end)

          neighbourList =
            if(isLeft(count, numNodes)) do
              neighbourList =
                neighbourList ++ [Enum.fetch!(num, count + 1)] ++ [Enum.fetch!(num, numNodes - 1)]

              neighbourList
            else
              neighbourList
            end

          neighbourList =
            if(isRight(count, numNodes)) do
              neighbourList =
                neighbourList ++ [Enum.fetch!(num, count - 1)] ++ [Enum.fetch!(num, 1)]

              neighbourList
            else
              neighbourList
            end

          neighbourList =
            if(!isRight(count, numNodes) && !isLeft(count, numNodes)) do
              neighbourList =
                neighbourList ++ [Enum.fetch!(num, count - 1)] ++ [Enum.fetch!(num, count + 1)]

              neighbourList
            else
              neighbourList
            end

          neighbourList =
            if(!isFront(count, numNodes) && !isLast(count, numNodes)) do
              mover = trunc(:math.pow(numNodes, 0.3333334))
              mover = mover * mover

              neighbourList =
                neighbourList ++
                  [Enum.fetch!(num, count + mover)] ++ [Enum.fetch!(num, count - mover)]

              neighbourList
            else
              neighbourList
            end

          neighbourList =
            if(!isFront(count, numNodes) && isLast(count, numNodes)) do
              mover = trunc(:math.pow(numNodes, 0.3333334))
              mover = mover * mover

              neighbourList =
                neighbourList ++
                  [Enum.fetch!(num, count - mover)] ++ [Enum.fetch!(num, numNodes - mover)]

              neighbourList
            else
              neighbourList
            end

          neighbourList =
            if(!isLast(count, numNodes) && isFront(count, numNodes)) do
              mover = trunc(:math.pow(numNodes, 0.3333334))
              mover = mover * mover

              neighbourList =
                neighbourList ++
                  [Enum.fetch!(num, count + mover)] ++ [Enum.fetch!(num, mover)]
            else
              neighbourList
            end

          neighbourList =
            if(!isTop(count, numNodes) && !isBottom(count, numNodes)) do
              mover = trunc(:math.pow(numNodes, 0.3333334))

              neighbourList =
                neighbourList ++
                  [Enum.fetch!(num, count + mover)] ++ [Enum.fetch!(num, count - mover)]

              neighbourList
            else
              neighbourList
            end

          neighbourList =
            if(!isTop(count, numNodes) && isBottom(count, numNodes)) do
              mover = trunc(:math.pow(numNodes, 0.3333334))

              neighbourList =
                neighbourList ++
                  [Enum.fetch!(num, count - mover)] ++ [Enum.fetch!(num, numNodes - mover)]

              neighbourList
            else
              neighbourList
            end

          neighbourList =
            if(isTop(count, numNodes) && !isBottom(count, numNodes)) do
              mover = trunc(:math.pow(numNodes, 0.3333334))

              neighbourList =
                neighbourList ++
                  [Enum.fetch!(num, count + mover)] ++ [Enum.fetch!(num, mover)]

              neighbourList
            else
              neighbourList
            end

          toNeighbourList(k, neighbourList)
        end)

      topology = "rand2D" ->
        listNodes = Enum.zip(listRandomNodes(Enum.count(num)), listRandomNodes(Enum.count(num)))

        Enum.each(num, fn x ->
          i = Enum.find_index(num, fn y -> y == x end)
          otherThanI = Enum.fetch!(listNodes, i)
          numNodes = Enum.count(num)

          nodesList =
            Enum.filter(0..(numNodes - 1), fn y ->
              isNeighbour(otherThanI, Enum.at(listNodes, y))
            end)

          neighbourList = Enum.map_every(nodesList, 1, fn x -> Enum.at(num, x) end)
          toNeighbourList(x, neighbourList)
        end)

      topology = "honeycomb" ->
        numNodes = Enum.count(num)
        rowLength = round(:math.sqrt(numNodes))

        Enum.each(num, fn x ->
          neighbourList = []
          index = Enum.find_index(num, fn y -> y == x end)

          cond do
            index <= rowLength - 1 && rem(rem(index, rowLength), 2) != 0 ->
              neighbourList =
                neighbourList ++ [Enum.at(num, index - 1), Enum.at(num, index + rowLength)]

              toNeighbourList(x, neighbourList)

            index <= rowLength - 1 && rem(rem(index, rowLength), 2) == 0 &&
                rowLength - rem(index, rowLength) != 1 ->
              neighbourList =
                neighbourList ++ [Enum.at(num, index + 1), Enum.at(num, index + rowLength)]

              toNeighbourList(x, neighbourList)

            index <= rowLength - 1 && rem(rem(index, rowLength), 2) == 0 &&
                rowLength - rem(index, rowLength) == 1 ->
              neighbourList = neighbourList ++ [Enum.at(num, index + rowLength)]
              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) != 0 && rem(rem(index, rowLength), 2) != 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index - 1),
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) != 0 && rem(rem(index, rowLength), 2) == 0 &&
                rowLength - rem(index, rowLength) != 1 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + 1),
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) == 0 && rem(rem(index, rowLength), 2) != 0 &&
                rem(index, rowLength) != 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + 1),
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) == 0 && rem(rem(index, rowLength), 2) == 0 &&
                rem(index, rowLength) != 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index - 1),
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) == 0 && rem(rem(index, rowLength), 2) == 0 &&
                rem(index, rowLength) == 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) == 0 && rem(rem(index, rowLength), 2) != 0 &&
                rem(index, rowLength) == 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) != 0 && rem(rem(index, rowLength), 2) != 0 &&
                rowLength - rem(index, rowLength) == 1 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) != 0 && rem(rem(index, rowLength), 2) == 0 &&
                rowLength - rem(index, rowLength) == 1 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)
          end
        end)

      topology = "randhoneycomb" ->
        numNodes = Enum.count(num)
        rowLength = round(:math.sqrt(numNodes))

        Enum.each(num, fn x ->
          neighbourList = []
          index = Enum.find_index(num, fn y -> y == x end)
          neighbourList = neighbourList ++ Enum.random(num -- x)

          cond do
            index <= rowLength - 1 && rem(rem(index, rowLength), 2) != 0 ->
              neighbourList =
                neighbourList ++ [Enum.at(num, index - 1), Enum.at(num, index + rowLength)]

              toNeighbourList(x, neighbourList)

            index <= rowLength - 1 && rem(rem(index, rowLength), 2) == 0 &&
                rowLength - rem(index, rowLength) != 1 ->
              neighbourList =
                neighbourList ++ [Enum.at(num, index + 1), Enum.at(num, index + rowLength)]

              toNeighbourList(x, neighbourList)

            index <= rowLength - 1 && rem(rem(index, rowLength), 2) == 0 &&
                rowLength - rem(index, rowLength) == 1 ->
              neighbourList = neighbourList ++ [Enum.at(num, index + rowLength)]
              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) != 0 && rem(rem(index, rowLength), 2) != 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index - 1),
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) != 0 && rem(rem(index, rowLength), 2) == 0 &&
                rowLength - rem(index, rowLength) != 1 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + 1),
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) == 0 && rem(rem(index, rowLength), 2) != 0 &&
                rem(index, rowLength) != 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + 1),
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) == 0 && rem(rem(index, rowLength), 2) == 0 &&
                rem(index, rowLength) != 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index - 1),
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) == 0 && rem(rem(index, rowLength), 2) == 0 &&
                rem(index, rowLength) == 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) == 0 && rem(rem(index, rowLength), 2) != 0 &&
                rem(index, rowLength) == 0 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) != 0 && rem(rem(index, rowLength), 2) != 0 &&
                rowLength - rem(index, rowLength) == 1 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)

            rem(div(index, rowLength) + 1, 2) != 0 && rem(rem(index, rowLength), 2) == 0 &&
                rowLength - rem(index, rowLength) == 1 ->
              neighbourList =
                neighbourList ++
                  [
                    Enum.at(num, index + rowLength),
                    Enum.at(num, index - rowLength)
                  ]

              toNeighbourList(x, neighbourList)
          end
        end)

      true ->
        IO.puts("Please check the arguments")
        System.halt(1)
    end

    startTime = System.monotonic_time(:millisecond)
    deletedNodes = randomDelete(num, errorNodes, 0, [])
    deleteNeighbours(num, deletedNodes)

    cond do
      algorithm == "gossip" ->
        Algorithm.startGossip(num, startTime, errorNodes)

      algorithm == "push-sum" ->
        Algorithm.startPushSum(num, startTime, errorNodes)
        loop()
    end
  end

  def loop() do
    loop()
  end

  def getDifference(a, b, c, d) do
    abs(a / b - c / d)
  end

  def handle_cast({:pushsum, new_s, new_w, startTime, length, errorNodes}, state) do
    {s, count, neighboursList, w} = state
    this_s = s + new_s
    this_w = w + new_w

    difference = getDifference(this_s, this_w, s, w)

    if(difference < :math.pow(10, -10) && count == 2) do
      count1 = :ets.update_counter(:table, "count", {2, 1})

      if count1 == length - errorNodes do
        new = System.monotonic_time(:millisecond)
        endTime = new - startTime
        IO.puts("Total time taken: #{endTime} milliseconds")
        System.halt(1)
      end
    end

    count =
      if(difference < :math.pow(10, -10) && count < 2) do
        count + 1
      else
        0
      end

    state = {this_s / 2, count, neighboursList, this_w / 2}
    newNode = Enum.random(neighboursList)
    Algorithm.sendPushSum(newNode, this_s / 2, this_w / 2, startTime, length, errorNodes)
    {:noreply, state}
  end

  def createNodes(numNodes) do
    Enum.map(1..numNodes, fn x ->
      pid = start_node()
      newState(pid, x)
      pid
    end)
  end

  def createTable do
    table = :ets.new(:table, [:named_table, :public])
    :ets.insert(table, {"count", 0})
  end

  def toNeighbourList(pid, list) do
    GenServer.call(pid, {:toNeighbourList, list})
  end

  def newState(pid, node) do
    GenServer.call(pid, {:newState, node})
  end

  def getAdjacentList(pid) do
    GenServer.call(pid, {:getAdjacent})
  end

  def getcount(pid) do
    GenServer.call(pid, {:getcount})
  end

  def updatecount(pid, start_time, length, errorNodes) do
    GenServer.call(pid, {:updatecount, start_time, length, errorNodes})
  end

  def handle_call({:toNeighbourList, list}, _from, state) do
    {a, b, _c, d} = state
    state = {a, b, list, d}
    {:reply, a, state}
  end

  def handle_call({:newState, node}, __from, state) do
    {a, b, c, d} = state
    state = {node, b, c, d}
    {:reply, a, state}
  end

  def handle_call({:getAdjacent}, _from, state) do
    {_a, _b, c, _d} = state
    {:reply, c, state}
  end

  def handle_call({:getcount}, _from, state) do
    {_a, b, _c, _d} = state
    {:reply, b, state}
  end

  def handle_call({:updatecount, start_time, length, errorNodes}, _from, state) do
    {a, b, c, d} = state

    if(b == 0) do
      count = :ets.update_counter(:table, "count", {2, 1})

      if(count == length - errorNodes) do
        end_time = System.monotonic_time(:millisecond) - start_time
        IO.puts("Time taken = #{end_time} milliseconds")
        System.halt(1)
      end
    end

    state = {a, b + 1, c, d}
    {:reply, b + 1, state}
  end

  def randomDelete(nodes, errorNodes, count, deletedNodes) do
    newNodes = []
    deleted = []

    if(count < errorNodes) do
      random = Enum.random(nodes)

      newNodes =
        if(Process.alive?(random) == true) do
          newNodes = List.delete(nodes, random)
          deleted = deletedNodes ++ [random]
          Process.exit(random, :normal)
          randomDelete(newNodes, errorNodes, count + 1, deleted)
        else
          randomDelete(newNodes, errorNodes, count, deleted)
        end
    else
      deletedNodes
    end
  end

  def deleteNeighbours(new, deleted) do
    Enum.each(new, fn x ->
      deleteFromNeighbours(x, deleted)
    end)
  end

  def deleteFromNeighbours(pid, deleted) do
    neighbourList = getAdjacentList(pid)

    newAdjacentList =
      Enum.filter(neighbourList, fn x ->
        Enum.member?(deleted, x) == false
      end)

    toNeighbourList(pid, newAdjacentList)
  end
end
