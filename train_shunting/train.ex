defmodule Train do
  # States: main-track, "one"-track, "two"-track

  def start(), do: []
  def start(trains) do trains end

  def add(atom, []), do: atom
  def add(atom, [wagon|train]) do
    if(atom != wagon) do
      [wagon | add(atom, train)]
    else
      [wagon | train]
    end
  end

  def start_tracks(), do: {[], [], []}
  def start_tracks(main, one, two), do: {main, one, two}

  def valid([]), do: true
  def valid([wagon|train]) do
    if (member(train, wagon)) do
      false
    else
      valid(train)
    end
  end


  # TRAIN
  def take(_, 0), do: []
  def take([], _), do: []
  def take(_ , n) when is_integer(n) and n < 0, do: []
  def take([wagon|train], n) when is_integer(n) and n > 0 do
    [wagon | take(train, n-1)]
  end

  def drop(train, 0), do: train
  def drop([], _), do: []
  def drop(train, n) when is_integer(n) and n < 0, do: train
  def drop([_ | train], n) when is_integer(n) and n > 0 do
    drop(train, n-1)
  end

  def append(train1, train2), do: train1 ++ train2

  def position(train, wagon) do
    position(train, wagon, 1)
  end
  # WILL NEVER BE REACHED; ASSUMING wagon EXISTS IN train
  def position([], _, _) do :invalid end
  def position([wagon|_], wagon, pos), do: pos
  def position([_ | train], wagon, pos), do: position(train, wagon, pos + 1)

  def member([], _val), do: false
  def member([h|t], val) do
    if (val != h) do
      member(t, val)
    else
      true
    end
  end

  def split([], _), do: []
  def split(train, splitter_wagon) do
    split(train, splitter_wagon, [])
  end
  def split([splitter_wagon|train], splitter_wagon, acc), do: {Enum.reverse(acc), train}
  def split([wagon|train], splitter_wagon, acc) do
    split(train, splitter_wagon, [wagon|acc])
  end

  def main(train, n) do
    # Keep track of where to start to give away with "lenght(train)-n"
    main(train, n, [], length(train) - n)
  end

  # "acc" keeps track of trains not to send, that is, those who stay in the current track
  def main([], n, acc, 0) do {n-length(acc), [], Enum.reverse(acc)} end
  # if there are trains left, but start_pos is 0, means we can send the remaining trains
  def main(train, _, acc, 0) do {0, Enum.reverse(acc), train} end
  # start_pos is negative, which means we want to send more than what is available in the train
  def main(train, _, acc, start_pos) when start_pos < 0 do {abs(start_pos), acc, train} end
  # Recursivly add the trains NOT to send into "acc"
  def main([wagon|train], n, acc, start_pos) when start_pos > 0 do
    main(train, n, [wagon|acc], start_pos-1)
  end

  # MOVES
  # One move on One train-track
  def single({:one, val}, {m, one, two}) do
    if(val > 0) do
      {_, remaining, take} = main(m, val)
      {remaining, append(take, one), two}
    else
      if(val < 0) do
        to_main = take(one, -val)
        to_stay = drop(one, -val)
        {append(m, to_main), to_stay, two}
      else
        {m,one,two}
      end
    end
  end

  def single({:two, val}, {m, one, two}) do
    if(val > 0) do
      {_, remaining, take} = main(m, val)
      {remaining, one, append(take, two)}
    else
      if(val < 0) do
        to_main = take(two, -val)
        to_stay = drop(two, -val)
        {append(m, to_main), one, to_stay}
      else
        {m,one,two}
      end
    end
  end
  def sequence([], state), do: [state]
  def sequence([move|sequences], state) do
    [state | sequence(sequences, single(move, state))]
  end

  # SHUNTING
  # Find tranformation of xs to ys
  # train1 = {xs, [], []}
  # train2 = {ys, [], []}
  def find([], []), do: []
  def find(train1, [marked_wag|rest]) do
      {hs, ts} = split(train1, marked_wag)

      one = [marked_wag | ts]
      two = hs

      [_ | uncorrect_wags] = one ++ two
      [{:one, length(one)}, {:two, length(two)}, {:one, -length(one)}, {:two, -length(two)} | find(uncorrect_wags, rest)]
  end

  # Find tranformation of xs to ys WITH reduced steps
  def few([], []), do: []
  def few(train1 = [mark|reminder], [marked_wag|rest]) do
    if(mark != marked_wag) do
      {hs, ts} = split(train1, marked_wag)

      one = [marked_wag | ts]
      two = hs

      [_ | uncorrect_wags] = one ++ two
      [{:one, length(one)}, {:two, length(two)}, {:one, -length(one)}, {:two, -length(two)} | few(uncorrect_wags, rest)]
    else
      few(reminder, rest)
    end
  end
  def rules([]), do: []
  def rules([{:one, _}]), do: []
  def rules([{:two, _}]), do: []
  def rules([step|rest]) do
    rules(rest, step, [step])
  end
  def rules([], _, acc) do Enum.reverse(acc) end
  def rules([step | rest], prev, acc) do
    [_|reminder] = acc
    case ({step, prev}) do
      {{:one, m}, {:one, m}} ->
        rules(rest, step, [{:one, m*2}|reminder])
      {{:one, m}, {:one, n}} ->
        rules(rest, step, [{:one, m+n}|reminder])

      {{:two, m}, {:two, m}} ->
        rules(rest, step, [{:two, m*2}|reminder])
      {{:two, m}, {:two, n}} ->
        rules(rest, step, [{:two, m+n}|reminder])

      {{:one, 0}, _} ->
        rules(rest, step, acc)
      {{:two, 0}, _} ->
        rules(rest, step, acc)
      {_,_} ->
        rules(rest, step, [step|acc])
    end
  end

  def compress(step_list) do
    maybe_correct_steps = rules(step_list)
    if(maybe_correct_steps == step_list) do
      step_list
    else
      compress(maybe_correct_steps)
    end
  end
end
