defmodule Eval do
  @type expr() :: {:add, expr(), expr()}
              | {:sub, expr(), expr()}
              | {:mul, expr(), expr()}
              | {:div, expr(), expr()}
              | literal()
  @type literal() :: {:num, integer()} | {:var, atom()} | {:q, integer(), integer()}

  @type environ() :: [{{:var, atom()},{:num, integer()}}|environ()]
                  | [{{:var, atom()},{:q, integer(), integer()}}|environ()]
                  | []

  def test1() do
    expr = {:div, {:mul, {:num, 2},{:add, {:var, :x}, {:var, :x}}}, {:q, 4, 6}}
    environment = environ_new([{{:var, :x},{:q, 3, 2}}])
    evaluated_expr_value = simple(eval(expr, environment))
    if(tuple_size(evaluated_expr_value) == 3) do
      {:q, n, m} = evaluated_expr_value
      IO.puts("Float value: #{n} / #{m}")
    else
      {:num, n} = evaluated_expr_value
      IO.puts("Integer value: #{n}")
    end
  end
  def test2() do
    expr = {:div, {:var, :x}, {:var, :y}}
    environment = environ_new([{{:var, :x},{:q, 3, 4}}, {{:var, :y},{:q, 5, 4}}])
    evaluated_expr_value = simple(eval(expr, environment))
    if(tuple_size(evaluated_expr_value) == 3) do
      {:q, n, m} = evaluated_expr_value
      IO.puts("Float value: #{n} / #{m}")
    else
      {:num, n} = evaluated_expr_value
      IO.puts("Integer value: #{n}")
    end
  end

  def eval({:num, n}, _) do {:num, n} end
  def eval({:var, v}, environ) do environ_find(environ, v) end
  def eval({:q, n, m}, _) do {:q, n, m} end
  def eval({:add, e1, e2}, environ) do
    add(eval(e1, environ), eval(e2, environ))
  end
  def eval({:sub, e1, e2}, rest) do
    sub(eval(e1, rest), eval(e2, rest))
  end
  def eval({:mul, e1, e2}, rest) do
    mul(eval(e1, rest), eval(e2, rest))
  end
  def eval({:div, e1, e2}, rest) do
    divi(eval(e1, rest), eval(e2, rest))
  end

  def add({:num, e1}, {:num, e2}) do {:num, e1 + e2} end
  def add({:q, n, m}, {:num, e2}) do {:q, e2*m + n, m} end
  def add({:num, e1}, {:q, n, m}) do {:q, e1*m + n, m} end
  def add({:q, n1, m1}, {:q, n2, m2}) do {:q, n1*m2 + n2*m1, m1*m2} end
  def add(e1, e2) do {:add, e1, e2} end

  def sub({:num, e1}, {:num, e2}) do {:num, e1 - e2} end
  def sub({:q, n, m}, {:num, e2}) do {:q, n - (e2*m), m} end
  def sub({:num, e1}, {:q, n, m}) do {:q, (e1*m) - n, m} end
  def sub({:q, n1, m1}, {:q, n2, m2}) do {:q, n1*m2 - n2*m1, m1*m2} end
  def sub(e1, e2) do {:sub, e1, e2} end

  def mul({:num, e1}, {:num, e2}) do {:num, e1 * e2} end
  def mul({:num, e2}, {:q, n, m}) do {:q, e2*n, m} end
  def mul({:q, n, m}, {:num, e1}) do {:q, n*e1, m} end
  def mul({:q, n1, m1}, {:q, n2, m2}) do {:q, n1*n2, m1*m2} end
  def mul(e1, e2) do {:mul, e1, e2} end

  # left_num diveded by right_num
  def divi({:num, e1}, {:num, e2}) do {:q, e1, e2} end
  def divi({:num, e1}, {:q, n, m}) do {:q, e1*m, n} end
  def divi({:q, n, m}, {:num, e1}) do {:q, n, m*e1} end
  def divi({:q, n1, m1}, {:q, n2, m2}) do {:q, n1*m2, m1*n2} end
  def divi(e1, e2) do {:div, e1, e2} end

  def math_gcd(e1, 0) do e1 end
  def math_gcd(e1, e2) do math_gcd(e2, rem(e1, e2)) end

  def environ_new([]) do [] end
  def environ_new(newList) do newList end

  def environ_find([], {:var, v}) do {:var, v} end
  def environ_find([{{:var, v},{:num, n}} | _], v) do {:num, n} end
  def environ_find([{{:var, v},{:q, n, m}} | _], v) do {:q, n, m} end
  def environ_find([_ | rest], var) do environ_find(rest, var) end

  def simple({:q, n, m}) do
    gcd = math_gcd(n, m)
    {:q, new_n, new_m} = {:q, round(n/gcd), round(m/gcd)}
    if(new_m == 1) do
      {:num, new_n}
    else
      {:q, new_n, new_m}
    end
  end
  def simple({:num, n}) do {:num, n} end

end
