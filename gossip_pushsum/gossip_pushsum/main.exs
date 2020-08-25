args = System.argv()
numNodes = String.to_integer(Enum.at(args, 0))
topology = Enum.at(args, 1)
algorithm = Enum.at(args, 2)

GossipPushSum.main(numNodes, topology, algorithm)