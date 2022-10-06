defmodule MerkleNode do
  @moduledoc """
  Node is the atomic unit of a Merkle tree

  Every node will have a value, (which is the hash of the content) and
  children list
  """

  @type t :: %MerkleNode{
    value: String.t(),
    children: list(MerkleNode.t())
  }

  defstruct(
    value: "",
    children: []
  )

  @spec new(String.t(), list()) :: MerkleNode.t()
  def new(value, children) do
    %MerkleNode{
      value: value,
      children: children
    }
  end

  @doc """
  Builds a Merkle tree out of the given content in list
  """
  @spec build(list()) :: MerkleNode.t()
  def build(contents) do
    # 1. Build the list of leaf nodes from the contents
    Enum.map(contents, fn content ->
      :crypto.hash(:sha256, content)
      |> Base.encode32()
      |> new([])
    end)
    |> build_tree()
    # 2. Build the tree from bottom up from list of leaf nodes
  end

  @spec build_tree(list(MerkleNode.t())) :: MerkleNode.t()
  defp build_tree([root]), do: root
  defp build_tree(nodes) do
    #  Get the chunk by 2
    # for each chunk, concatenate the values and make hash of that
    # create new node
    parent_nodes = Enum.chunk_every(nodes, 2)
    |> Enum.map(fn children ->
        Enum.reduce(children, "", fn %MerkleNode{} = child, hash ->
          child_hash = :crypto.hash(:sha256, child.value) |> Base.encode32()
          hash <> child_hash
        end)
        |> new(children)
    end)
    build_tree(parent_nodes)
  end
end
