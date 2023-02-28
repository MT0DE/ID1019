defmodule Derivation do
  @type literal() :: {:num, number()} | {:var, atom()}
  @type expr() :: {:add, expr(), expr()} | {:mul, expr(), expr()} |
                  {:pot, expr(), number()} | {:ln, expr()} |
                  {:inv, expr()} | {:sqr, expr()} | {:sin, expr()} | literal()

# test for (a)ddition and (m)ultiplikation
  def test_am() do
    x = {:add,
      {:mul, {:num, 2}, {:var, :x}},
      {:num, 3}}
    d = deriv(x, :x)
    IO.write("expr: #{better_print(simplify(x))}\n")
    IO.write("deriavtion_of_expr: #{better_print(simplify(d))}\n")
  end
  def test_poly() do
    x = {:add,
          {:pot, {:var, :x}, {:num, 2}},
          {:add,
            {:mul, {:num, 2}, {:var, :x}},
            {:num, 3}}}
    d = deriv(x, :x)
    IO.write("expr: #{better_print(simplify(x))}\n")
    IO.write("deriavtion_of_expr: #{better_print(simplify(d))}\n")
  end
  def test_pot() do
    x = {:add,
      {:pot, {:add, {:pot, {:var, :x}, {:num, 2}}, {:num, 4}}, {:num, 5}},
      {:num, 3}}
    d = deriv(x, :x)
    IO.write("expr: #{better_print(simplify(x))}\n")
    IO.write("deriavtion_of_expr: #{better_print(simplify(d))}\n")
  end
  def test_ln() do
    x = {:ln, {:mul, {:num, 5}, {:var, :x}}}
    d = deriv(x, :x)
    IO.write("expr: #{better_print(simplify(x))}\n")
    IO.write("deriavtion_of_expr: #{better_print(simplify(d))}\n")
  end
  def test_sqr do
    x = {:sqr, {:mul, {:num, 5}, {:pot, {:var, :x}, {:num, 2}}}}
    d = deriv(x, :x)
    IO.write("expr: #{better_print(simplify(x))}\n")
    IO.write("deriavtion_of_expr: #{better_print(simplify(d))}\n")
  end
  # Number/Variable
  def deriv({:num, _}, _) do {:num, 0} end
  def deriv({:var, v}, v) do {:num, 1} end
  def deriv({:var, _}, _) do {:num, 0} end
  # Multiplikation
  def deriv({:mul, e1, e2}, v) do
    {:add,
     {:mul, deriv(e1, v), e2},
     {:mul, e1, deriv(e2, v)}}
  end
  # Addition
  def deriv({:add, e1, e2}, v) do
    {:add, deriv(e1, v), deriv(e2, v)}
  end
  # Enkla potenser
  def deriv({:pot, e, {:num, n}}, v) do
      {:mul,
          {:mul,
              {:num, n},
              deriv(e, v)},
          {:pot, e, {:num, n-1}}}
  end
  # Naturliga logaritmen
  def deriv({:ln, exp}, v) do
    {:mul, deriv(exp, v), {:inv, exp}}
  end
  # Inverer(?)
  def deriv({:inv, exp}, v) do
    {:mul, {:num, -1}, {:mul, deriv(exp, v), {:inv, {:pot, exp, {:num, 2}}}}}
  end
  # Kvadratroten
  def deriv({:sqr, exp}, v) do
    {:mul, deriv(exp,v), {:inv, {:mul, {:num, 2}, {:sqr, exp}}}}
  end


  def simplify({:add, e1, e2}) do
    simplify_add(simplify(e1), simplify(e2))
  end
  def simplify({:mul, e1, e2}) do
    simplify_mul(simplify(e1), simplify(e2))
  end
  def simplify({:pot, e1, e2}) do
    simplify_pot(simplify(e1), simplify(e2))
  end
  # cannot simplify natural logarithm
  # cannot simplify a inverse
  def simplify({:sqr, exp}) do
    simplify_sqr(simplify(exp))
  end
  def simplify(n) do n end

  def simplify_add({:num, 0}, e2) do e2 end
  def simplify_add(e1, {:num, 0}) do e1 end
  def simplify_add({:num, e1}, {:num, e2}) do {:num, e1+e2} end
  def simplify_add(e1, e2) do {:add, e1, e2} end


  def simplify_mul({:num, 0}, _) do {:num, 0} end
  def simplify_mul(_, {:num, 0}) do {:num, 0} end
  def simplify_mul({:num, 1}, e2) do e2 end
  def simplify_mul(e1, {:num, 1}) do e1 end
  def simplify_mul({:num, e1}, {:num, e2}) do {:num, e1*e2} end
  def simplify_mul(e1, e2) do {:mul, e1, e2} end

  def simplify_pot(_, {:num, 0}) do {:num, 1} end
  def simplify_pot(exps, {:num, 1}) do exps end
  def simplify_pot(e1, e2) do {:pot, e1, e2} end

  def simplify_sqr({:num, 0}) do {:num, 0} end
  def simplify_sqr({:num, 1}) do {:num, 1} end
  def simplify_sqr(e) do {:sqr, e} end


  # Pretty-fied
  def better_print({:num, v}) do "#{v}" end
  def better_print({:var, v}) do "#{v}" end
  def better_print({:add, e1, e2}) do "(#{better_print(e1)} + #{better_print(e2)})" end
  def better_print({:mul, e1, e2}) do "#{better_print(e1)} * #{better_print(e2)}" end
  def better_print({:pot, exp, {:num, n}}) do "#{better_print(exp)}^#{n}" end
  def better_print({:ln, exp}) do "ln(#{better_print(exp)})" end
  def better_print({:inv, exp}) do "1/(#{better_print(exp)})" end
  def better_print({:sqr, e}) do "sqrt(#{better_print(e)})" end
end
