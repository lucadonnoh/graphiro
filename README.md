# Graphiro

## Introduction

### Graphs utility
Graphs can be used in any application that needs to model relations between object.
They can be used for representing maps in games, establish relations between players or users of a protocol.
Another application of graphs is building Finite State Machines, useful for example for games like Axelrod where some strategies are represented with a FSM.

<div style="displsy:flex">
<img src="https://user-images.githubusercontent.com/30298476/178510653-b133c590-777f-46f8-9af1-00b6b480ecee.png" width="250" height="200"/>
<img src="https://user-images.githubusercontent.com/30298476/178511633-489a5748-0f50-49f1-a2f0-6cb5076bde52.jpeg" width="300" height="200"/>
<img src="https://user-images.githubusercontent.com/30298476/178512519-2cd45b07-14ed-43ef-8e6e-184b6e59f624.png" width="400" height="200/>
</div>
 
### Graphs representation
There are three main ways to represent a graph:
- Adjacency matrix
- Adjacency list
- Edge list

The edge list representation is usually the most expensive, while the other two are quite efficient and offer different trade-offs.
So, in this library I decided to use the edge list representation.

Wait what?

Since cairo works only with recursion, the edge list representation is the one that only uses recursive structure and therefore feels more natural.
Another limitation is that it is not currently possible to create a mapping to an array (no pointers allowed).

The graph assumes there exists `felt.SIZE` nodes and just saves the information about edges.
`edge` is a structure with two members: source and destination.
The edge list maps an index to an `edge` structure.

The supported external functions are the following:
- `add_edge`: add an edge to the edge list
- `are_adjacent`: check that two nodes are adjacent
- `reachable`: check if there is a path between two nodes with a DFS

The next important function to implement is the one that returns the [component](https://en.wikipedia.org/wiki/Component_(graph_theory)) of a given vertex.
