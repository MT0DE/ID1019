defmodule Huffman do
  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
  end
  def text() do
    'this is something that we should encode'
  end
  def test do
    sample = sample()
    tree = tree(sample)
    encode = encode_table(tree)
    text = text()
    seq = encode(text, encode)
    decode(seq, tree)
  end
  def tree(sample) do
    freq = freq(sample)
    huffman(freq)
  end
  def encode_table(tree) do
    encode_table(tree, [], [])
  end
  def encode_table({key, value}=leaf, curr_path, paths) when is_integer(key) do PriorityList.push(paths, {key, curr_path}) end
  def encode_table({{left, right}, value}=tree, curr_path, paths) do
    one_branch = encode_table(left, PriorityList.push(curr_path, 0), paths)
    encode_table(right, PriorityList.push(curr_path, 1), one_branch)
  end

  def decode_table(tree) do
    # To implement...
  end

  # To create the list of bits, just add each code (not tail-recursive tho)
  def encode([], table), do: []
  def encode([char | rest], table) do
    {_, code} = Frequency.lookup(table, char)
    code ++ encode(rest, table)
  end


  def decode(seq, tree) do
    decode(seq, tree, [])
  end
  def decode([], _, acc) do Enum.reverse(acc) end
  def decode(seq, tree, acc) do
    # rör sig i trädet tills en bokstav är återfod, fortsätt med resternade
    {char, rest} = decode_char(seq, tree) #logaritmiskt sök-tid
    decode(rest, tree, [char | acc])
  end

  def decode_char(rest, {char, _}) when is_integer(char) do {char, rest} end
  def decode_char([bit | rest], {{left, right}, _}) do
    case bit do
      0 ->
        decode_char(rest, left)
      1 ->
        decode_char(rest, right)
    end
  end

  # Representation of a node
  # {{left, right}, value}
  def huffman([]) do [] end
  def huffman([last]) do last end
  def huffman(list) do
    # Remove 2 values from the priority queue
    {right={_,v1}, list} = PriorityList.pop(list)
    {left={_,v2}, list} = PriorityList.pop(list)

    # create new external node with information
    node = {{left, right}, v1 + v2}
    list = PriorityList.push(list, node)
    list = Frequency.sort_desc_freq(list) # sort_desc_freq sorts only based on the value in {_, value <-[here] }
    huffman(list)
  end

  def freq(sample) do freq(sample, []) end
  def freq([], freq) do
    Frequency.sort_desc_freq(freq)
  end
  def freq([char | rest], freq) do
    freq = case Frequency.lookup(freq, char) do
      {k,v} ->
        Frequency.add(freq, k, v+1)
      :nil ->
        Frequency.add(freq, char, 1)
    end
    freq(rest, freq)
  end
end

defmodule Frequency do
  # List actions
  def add([], k, v) do [{k,v}] end
  def add([{key, _}|rest], key, value) do [{key, value}|rest] end
  def add([{k,v}|rest], key, value) do [{k,v}|add(rest, key, value)] end

  def lookup([], _) do :nil end
  def lookup([{k,v}|_], k) do {k,v} end
  def lookup([_|rest], key) do lookup(rest, key) end

  def remove(list, key) do remove(list, key, []) end
  def remove([], _, acc) do Enum.reverse(acc) end
  def remove([head|tail], key, acc) do
    if(elem(head, 0) == key) do
      remove(tail, key, acc)
    else
      remove(tail, key, [head|acc])
    end
  end

  def sort_desc_freq(list) do
    sort_desc_freq(list, [])
  end
  def sort_desc_freq([], acc) do acc end
  def sort_desc_freq(list, acc) do
    {k, v} = most_freq(list)
    list = remove(list, k)
    sort_desc_freq(list, add(acc, k, v))
  end

  def most_freq(list) do
    most_freq(list, List.first(list))
  end
  def most_freq([], set) do set end
  def most_freq([pot_high={_,v}|rest], curr_high={_, value}) do
    if(v > value) do
      most_freq(rest, pot_high)
    else
      most_freq(rest, curr_high)
    end
  end
end

defmodule PriorityList do
  # PriorityList queue actions (used for huffman tree)
  def push([], node) do [node] end
  def push([curr | rest], node) do
    [curr | push(rest, node)]
  end

  def pop(list) do pop(list, []) end
  def pop([], _) do {:nil, []} end
  def pop([last], acc) do {last, Enum.reverse(acc)} end
  def pop([elem|rest], acc) do
    pop(rest, [elem|acc])
  end
end
