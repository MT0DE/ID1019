defmodule Eatery do
  def bench() do
    {time, _} = :timer.tc(fn -> start() end)
    time
  end
  def start() do
    t1 = :erlang.timestamp()
    eatery = spawn(fn -> init(t1) end)
    eatery
  end
  def init(t1) do
    c1 = Chopstick.start()
    c2 = Chopstick.start()
    c3 = Chopstick.start()
    c4 = Chopstick.start()
    c5 = Chopstick.start()
    ctrl = self()
    n1 = :rand.uniform(20)
    n2 = :rand.uniform(20)
    n3 = :rand.uniform(20)
    n4 = :rand.uniform(20)
    n5 = :rand.uniform(20)
    Philosopher.start(100, c1, c2, "Arendt", ctrl)
    Philosopher.start(100, c2, c3, "Hypatia", ctrl)
    Philosopher.start(100, c3, c4, "Simone", ctrl)
    Philosopher.start(100, c4, c5, "Elisabeth", ctrl)
    Philosopher.start(100, c5, c1, "Ayn", ctrl) #using Anna bok-tekniken skulle ändra ordningen på "c5,c1" till "c1, c5" (tänk på låten Anna boks "ABC")
    wait(5, [c1, c2, c3, c4, c5], t1)
  end

  defp wait(0, chopsticks, t1) do
    Enum.each(chopsticks, fn(c) -> Chopstick.quit(c) end)
    t2 = :erlang.timestamp()
    execution_time = :timer.now_diff(t2, t1)
    :io.format("~5.2f secs~n", [execution_time/1_000_000])
  end
  defp wait(n, chopsticks, t1) do
    receive do
      :done ->
        wait(n-1, chopsticks, t1)
      :abort ->
        :io.format("dinner aborted~")
        Process.exit(self(), :kill)
    end
  end

  def stop() do
    case Process.whereis(:dinner) do
       nil ->
        nil
       pid ->
        send(pid, :abort)
    end
  end
end
