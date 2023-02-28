defmodule EnvTree do
  # CASES
  # 1. adding key to empty tree
  # 2. adding key already existing
  # 3. add new key to tree on left branch
  # 4. add new key to tree on right branch
  def add(nil, key, value) do {:node, key, value, nil, nil} end
  def add({:node, key, _, left, right}, key, value) do {:node, key, value, left, right} end
  def add({:node, k, v, left, right}, key, value) when key < k do {:node, k, v, add(left, key, value), right} end
  def add({:node, k, v, left, right}, key, value) when key > k do {:node, k, v, left, add(right, key, value)} end

  # CASES
  # 1. empty tree (think of each node as a tree, one tree is empty somewhere as a leaf)
  # 2. finding correct key
  # 3. search in left branch
  # 4. search in right branch
  def lookup(nil, _) do nil end
  def lookup({:node, key, value, _, _}, key) do {key, value} end
  def lookup({:node, k, _, left, _}, key) when key < k do lookup(left, key) end
  def lookup({:node, k, _, _, right}, key) when key > k do lookup(right, key) end


  # CASES
  # 1. empty tree (think of each node as a tree, one tree is empty somewhere as a leaf)
  # 2. tree with only one branch (2 subcases)
  # 3. finding correct key to remove
  # 4. search in left branch
  # 5. search in right branch
  def remove(nil, _) do nil end #Object does not exist
  def remove({:node, key, _, nil, right}, key) do right end #Promote right-tree
  def remove({:node, key, _, left, nil}, key) do left end #Promote left-tree
  def remove({:node, key, _, left, right}, key) do
    {:node, k ,v, _, _} = leftmost(right)
    {:node, k, v, left, remove(right, k)}
  end
  def remove({:node, k, v, left, right}, key) when key < k do
    {:node, k, v, remove(left, key), right}
  end
  def remove({:node, k, v, left, right}, key) when key > k do
    {:node, k, v, left, remove(right, key)}
end
  def leftmost({:node, key, value, nil, rest}) do {:node, key, value, nil, rest} end
  def leftmost({:node, _, _, left, _}) do
    {:node, k, v, l, r} = leftmost(left)
    {:node, k, v, l, r}
  end
end
