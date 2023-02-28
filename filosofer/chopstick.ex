defmodule Chopstick do
  def start() do
    stick = spawn_link(fn -> init() end)
    stick
  end
  def init() do
    IO.puts("shopstick started!")
    # local({:chopstick, self()})
    available()
  end

  # def local(msg) do
  #   case Process.whereis(:shell) do
  #      nil ->
  #       nil
  #      pid ->
  #       send(pid, msg)
  #   end
  # end

  def available() do
    receive do
      {:request, from} ->
        send(from, :granted)
        gone()
      :quit ->
        :ok
      :return -> IO.puts("")
    end
  end

  # Skickas ytterliggare {request, self()} till gone(), kommer den hamna i först i kö.
  # Och om den då går tillbaks till available() så skickas den och utför det som finns först i kön.
  def gone() do
    receive do
      :return ->
        available()
      :quit ->
        :ok
    end
  end

  # ANVÄNDS AV FILOSOFEN (Asynchronous, for deadlocks)
  def request(left, right, timeout) when is_integer(timeout) do
    # Lets send a request for left and then immideatly for right aswell
    # Then the granted function will be part of this function as hidden as
    # the recieve part
    send(left, {:request, self()})
    send(right, {:request, self()})
    granted(timeout) #Continue execution in granted function
  end
  defp granted(timeout) do
    receive do
      :granted ->
    after
      timeout ->
        :no
    end
    receive do
      :granted ->
        :ok
    after
      timeout ->
        :no
    end
  end


  # ANVÄNDS AV FILOSOFEN (for deadlocks)
  def request(pid, timeout) when is_integer(timeout) do
    send(pid, {:request, self()})
    receive do
      :granted -> :ok
    after
      timeout ->
        :no
    end
  end

  # ANVÄNDS AV FILOSOFEN (Synchronous)
  def request(pid) do
    send(pid, {:request, self()})
    receive do
      :granted -> :ok
    end
  end
  def return(pid) do
    send(pid, :return)
  end
  def quit(pid) do
    send(pid, :quit)
  end
end
