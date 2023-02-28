defmodule Hanoi do
  def test() do
    Enum.each(1..10, fn n -> IO.inspect("#{n} -> #{length(hanoi(n, :a, :b, :c))}") end)
  end
  def hanoi(0, _, _, _) do [] end
  def hanoi(n, from, aux, to) do
    hanoi(n-1, from, to, aux) ++
    [{:move, from, to}] ++
    hanoi(n-1, aux, from, to)
  end
end
