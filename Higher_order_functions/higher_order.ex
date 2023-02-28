defmodule HigherOrder do
    # FOR LAMBDA FUNCTIONS (MAP FUNCTION)
    def double([]) do [] end
    def double([h|t]) do
      [2*h|double(t)]
    end
    def five([]) do [] end
    def five([h|t]) do
      [h + 5|five(t)]
    end
    def animal([]) do [] end
    def animal([:dog|t]) do [:fido|animal(t)] end
    def animal([h|t]) do [h|animal(t)] end

    def double_five_animal([], _) do [] end
    def double_five_animal([h|t], op) do
      case op do
        :double -> if(is_integer(h)) do [h*2|double_five_animal(t, op)] else [h|double_five_animal(t, op)] end
        :five -> if(is_integer(h)) do [h+5|double_five_animal(t, op)] else [h|double_five_animal(t, op)] end
        :animal ->
          if(h == :dog) do
            [:fido|double_five_animal(t, op)]
          else
            [h|double_five_animal(t, op)]
          end
      end
    end
    # HigherOrder.double_five_animal([1,2,3,4], :double)
    # HigherOrder.double_five_animal([1,2,3,4], :five)
    # HigherOrder.double_five_animal([:dog,:horse,:cat,:hippopotamus], :animal)

    def apply_to_all([], _) do [] end
    def apply_to_all([h|t], fun) do
      [fun.(h)|apply_to_all(t, fun)]
    end
    # HigherOrder.apply_to_all([1,2,3,4], fn(x) -> x * 2 end)

    # FOLDING FUNCTIONs
    # def sum([]) do 0 end
    # def sum([h|t]) do
    #   h + sum(t)
    # end
    # HigherOrder.sum([1,2,3,4])

    def sum(list) do
      fold_left(list, 0, fn x, acc -> x + acc end)
    end

    def fold_right([], default, _) do default end
    def fold_right([h|t], default, f ) do
      f.(h, fold_right(t, default, f))
    end
    # HigherOrder.fold_left([1,2,3,4], 0, fn(x, acc) -> x+acc end)
    # HigherOrder.fold_left([1,2,3,4], 0, fn(x, acc) -> {x, acc} end)

    def fold_left([], default, _) do default end
    def fold_left([h|t], default, f) do
      fold_left(t, f.(h, default), f)
    end

    # FILTER FUNCTION
    def odd([]) do [] end
    def odd([h|t]) do
      if (rem(h, 2) == 0) do
        odd(t)
      else
        [h|odd(t)]
      end
    end
    # HigherOrder.odd([1,2,3,4,5,6,7,8])

    def filter([], _) do [] end
    def filter([h|t], fun) do
      if(fun.(h) == true) do
        [h|filter(t, fun)]
      else
        filter(t, fun)
      end
    end
    # HigherOrder.filter([1,2,3,4,5,6,7,8,9,10], fn(x) -> if rem(x,2) == 1, do: true, else: false end)
end
