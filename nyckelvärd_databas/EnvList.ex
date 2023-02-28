defmodule EnvList do
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
  # first add method with 3 arguments will soner or later call method with 4 arguments
  def add(map, key, value) do
    l = lookup(map,key)
    if(l == :nil) do
      [{key,value}|map]
    else
      map = add(map,key,value,[]) #akumulatorn [] samlar alla världen och lägger in det nya värdet på
      rev(map)
    end
  end
  # Accumulator-helper for add with 4 arguments
  def add([], _, _, acc) do acc end
  def add([head|tail], key, value, acc) do
    if(elem(head, 0) == key) do
      add(tail, key, value, [{key,value}|acc])
    else
      add(tail, key, value, [head|acc])
    end
  end

  # Lookup matching key-value pair by using key
  def lookup([], _) do :nil end
  def lookup([head|tail], key) do
    if(elem(head, 0) == key) do
      head
    else
      lookup(tail, key)
    end
  end

  # Remove one entry by matching with key (using accumulator)
  def remove(map, key) do remove(map, key, []) end
  def remove([], _, acc) do rev(acc) end
  def remove([head|tail], key, acc) do
    if(elem(head, 0) == key) do
      remove(tail, key, acc)
    else
      remove(tail, key, [head|acc])
    end
  end

  # Reverse-list function
  def rev(lst) do rev(lst, []) end
  def rev([], acc) do acc end
  def rev([h|t], acc) do
    rev(t, [h|acc])
  end
end
