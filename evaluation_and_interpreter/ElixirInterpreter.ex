defmodule Eager do
  # @type match() :: pattern() "=" expression()
  # @type sequence() :: expression() | match() ";" sequence()


  def test() do
    seq = [{:match, {:var, :x},
{:cons, {:atm, :a}, {:cons, {:atm, :b}, {:atm, []}}}},
{:match, {:var, :y},
{:cons, {:atm, :c}, {:cons, {:atm, :d}, {:atm, []}}}},
{:apply, {:fun, :append}, [{:var, :x}, {:var, :y}]}
]
Eager.eval_seq(seq, Env.new())
  end
  def test1() do
    seq = [{:match, {:var, :x}, {:atm, :a}},
{:match, {:var, :f},
{:lambda, [:y], [:x], [{:cons, {:var, :x}, {:var, :y}}]}},
{:apply, {:var, :f}, [{:atm, :b}]}
]
Eager.eval_seq(seq, Env.new())
  end

  def test2() do
    seq = [{:match, {:var, :x}, {:atm, :a}},
{:case, {:var, :x},
[{:clause, {:atm, :b}, [{:atm, :ops}]},
{:clause, {:atm, :a}, [{:atm, :yes}]}
]}
]
Eager.eval_seq(seq, Env.new())
  end
  def test3() do
    seq = [{:match, {:var, :x}, {:atm,:a}},
{:match, {:var, :y}, {:cons, {:var, :x}, {:atm, :b}}},
{:match, {:cons, :ignore, {:var, :z}}, {:var, :y}},
{:var, :z}]
Eager.eval(seq)
  end

def eval(seq) do
  eval_seq(seq, Env.new())
end

def eval_expr({:atm, id}, _) do {:ok, id} end
def eval_expr({:var, id}, env) do
  case Env.lookup(id, env) do
    nil ->
      :error

    {_, str} ->
      {:ok, str}
    end
  end
  def eval_expr({:cons, head, tail}, env) do
    case eval_expr(head, env) do
      :error ->
        :error

      {:ok, hs} ->
        case eval_expr(tail, env) do
          :error ->
            :error

          {:ok, ts} ->
            {:ok, {hs, ts}}
         end
      end
  end

  #Expression for "abstraction for Cases"
  def eval_expr({:case, expr, cls}, env) do
    case eval_expr(expr, env) do
      :error ->
        :error
      {:ok, str} ->
        eval_cls(cls, str, env)
    end
  end
  #Lambda exspression
  def eval_expr({:lambda, par, free, seq}, env) do
    case Env.closure(free, env) do
      :error ->
        :error
      closure ->
        {:ok, {:closure, par, seq, closure}}
    end
  end
  def eval_expr({:apply, expr, args}, env) do
    case eval_expr(expr, env) do
      :error ->
        :error
      {:ok, {:closure, par, seq, closure}} ->
        case eval_args(args, env) do
          :error ->
            :error
          {:ok, strs} ->
            env = Env.args(par, strs, closure)
            eval_seq(seq, env)
        end
      {:ok, _} ->
        :error
     end
  end
  #For name functions
  def eval_expr({:fun, id}, env) do
    {par, seq} = apply(Prgm, id, [])
    {:ok, {:closure, par, seq, env}}
    end

  def eval_match(:ignore, _, env) do
    {:ok, env}
  end
  def eval_match({:atm, id}, id, env) do
    {:ok, env}
  end
  def eval_match({:var, id}, str, env) do
    case Env.lookup(id, env) do
      nil ->
        {:ok, Env.add(id, str, env)}
      {id, ^str} ->  #remember value of str! (with "^" (pin) operator)
        {:ok, env}
      {_, _} ->
        :fail
      end
  end
  def eval_match({:cons, hp, tp}, {h2, t2}, env) do
    case eval_match(hp, h2, env) do
      :fail ->
        :fail
      {:ok, env} ->
        eval_match(tp, t2, env)
    end
  end
  def eval_match(_, _, _) do
    :fail
    end

  def eval_scope(str, env) do
    Env.remove(extract_vars(str), env)
    end
  def eval_seq([exp], env) do
    eval_expr(exp, env)
    end
  def eval_seq([{:match, ptr, exp} | seq], env) do
    case eval_expr(exp, env) do
    :error ->
      :error
    {:ok, str} ->
    env = eval_scope(ptr, env)
    case eval_match(ptr, str, env) do
      :fail ->
        :error
      {:ok, env} ->
        eval_seq(seq, env)
      end
    end
  end

  def eval_cls([], _, _) do
      :error
    end
  def eval_cls([{:clause, ptr, seq} | cls], str, env) do
    case eval_match(ptr, str, eval_scope(ptr, env)) do
      :fail ->
        eval_cls(cls, str, env)
      {:ok, env} ->
        eval_seq(seq, env)
      end
  end

  def eval_args(args, env) do
    eval_args(args, env, [])
  end

  def eval_args([], _, strs) do {:ok, Enum.reverse(strs)}  end
  def eval_args([expr | exprs], env, strs) do
    case eval_expr(expr, env) do
      :error ->
        :error
      {:ok, str} ->
        eval_args(exprs, env, [str|strs])
    end
  end

  def extract_vars(pattern) do
    extract_vars(pattern, [])
  end

  def extract_vars({:atm, _}, vars) do vars end
  def extract_vars(:ignore, vars) do vars end
  def extract_vars({:var, var}, vars) do [var|vars] end
  def extract_vars({:cons, head, tail}, vars) do extract_vars(tail, extract_vars(head, vars)) end

  # def extract_vars([{:var, var}|tail]) do [{:var, var}|extract_vals(tail)] end
  # def extract_vars([h|t]) do extract_vals(t) end
end

defmodule Env do
  def new() do [] end
  def new(lst) do lst end


  def add(id, val, env) do [{id, val} | env] end

  def lookup(_, []) do nil end
  def lookup(id, [{id, val}|_]) do {id, val} end
  def lookup(id, [_|t]) do lookup(id, t) end


  def remove(_, []) do [] end
  def remove(ids, [{id, val}|t]) do
    if (Enum.member?(ids, id)) do
      remove(ids, t)
    else
      [{id, val}|remove(ids, t)]
    end
  end

  #free_var is list of free variabels
  #env is the current environment
  def closure(keyss, env) do
    List.foldr(keyss, [], fn(key, acc) ->
      case acc do
        :error ->
          :error
        cls ->
          case lookup(key, env) do
            {key, value} ->
              [{key, value} | cls]

            nil ->
              :error
          end
      end
    end)
  end

  def args(pars, args, env) do
    List.zip([pars, args]) ++ env
  end
end
defmodule Prgm do
  def append() do
    {[:x, :y], [{:case, {:var, :x}, [{:clause, {:atm, []}, [{:var, :y}]}, {:clause, {:cons, {:var, :hd}, {:var, :tl}}, [{:cons, {:var, :hd}, {:apply, {:fun, :append}, [{:var, :tl}, {:var, :y}]}}] }] }] }
  end
end
