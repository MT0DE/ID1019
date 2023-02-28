defmodule Philosopher do

  @timeout 1000
  @eat 50
  @delay 50

  def start(hunger, left, right, name, ctrl) do
    spawn_link(fn -> init(hunger, left, right, name, ctrl) end)
  end

  defp init(hunger, left, right, name, ctrl) do
    dreaming(hunger, left, right, name, ctrl)
  end

  defp dreaming(0, _left, _right, name, ctrl) do
    IO.puts("#{name} is satisfied and goes to sleep: COMPLETED")
    send(ctrl, :done)
    # {_, _, secs} = :erlang.timestamp()
    # IO.puts("#{name} took #{secs/1000}")
  end

  defp dreaming(hunger, left, right, name, ctrl) do
    IO.puts("#{name} is happy although still hungry: #{hunger}")
    sleep(@timeout)
    waiting(hunger, left, right, name, ctrl)
  end

  defp waiting(hunger, left, right, name, ctrl) do
    IO.puts("#{name} is waiting for chopsticks patiently, hunger: #{hunger}")
    # case Chopstick.request(left, @timeout) do
    #   :ok ->
    #     IO.puts("#{name} got their left chopstick")
    #     sleep(@delay)
    #     case Chopstick.request(right, @timeout) do
    #       :ok ->
    #         IO.puts("#{name} got both chopsticks")
    #         eating(hunger, left, right, name, ctrl)
    #       :no ->
    #         IO.puts("#{name} aborted!")
    #         Chopstick.return(left)
    #         Chopstick.return(right) # Since the previous request will be sent into a stack in process (stick) the gone()-state
    #                                 # Once in the available()-state, that is being recognized, aka the stick is never returned
    #         dreaming(hunger, left, right, name, ctrl)
    #     end
    #   :no ->
    #     IO.puts("#{name} aborted!")
    #     dreaming(hunger, left, right, name, ctrl)
    # end

    case Chopstick.request(left, right, @timeout) do
      :ok ->
        IO.puts("#{name} got both chopsticks")
        eating(hunger, left, right, name, ctrl)
      :no ->
        IO.puts("#{name} aborted!")
        Chopstick.return(left)
        Chopstick.return(right) # Since the previous request will be sent into a stack in process (stick) the gone()-state
                                # Once in the available()-state, that is being recognized, aka the stick is never returned
        dreaming(hunger, left, right, name, ctrl)
    end
  end

  defp eating(hunger, left, right, name, ctrl) do
    IO.puts("#{name} is eating aggresivly, but is happy")

    sleep(@eat)

    Chopstick.return(left)
    Chopstick.return(right)

    dreaming(hunger-1, left, right, name, ctrl)
  end

  def sleep(0) do :ok end
  def sleep(t) do
    # :rand.uniforom() gives 1-800 ms delay
    :timer.sleep(:rand.uniform(t))
  end
end
