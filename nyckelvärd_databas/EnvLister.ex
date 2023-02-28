defmodule EnvLister do
  # Future-note: More pattern-matching could have been used

  def test_list() do
    a = new()
    a = add(a, :a, 10)
    a = add(a, :b, 20)
    a = add(a, :c, 30)
    a = add(a, :d, 40)
    #changing c-key's value
    a = add(a, :c, 20)
  end

  # Make an empty map
  def new() do [] end

  # Add one entry into this map
  def add([], key, value) do [{key, value}] end
  def add([{key, _} | tail], key, value) do [{key, value} | tail] end
  def add([{k, v} | tail], key, value) do [{k, v} | add(tail, key, value)] end

  # Lookup matching key-value pair by using key
  def lookup([], _) do :nil end
  def lookup([{key, value} | _], key) do {key, value} end
  def lookup([_|tail], key) do lookup(tail, key) end

  # Remove one entry by matching with key (using accumulator)
  def remove([], _) do [] end
  def remove([{key, _} | tail], key) do tail end
  def remove([{k, v} | tail], key) do [{k, v} | remove(tail, key)] end
end
