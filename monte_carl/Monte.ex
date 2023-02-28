defmodule Monte do
  def dart(r) do
    x = Enum.random(0..r)
    y = Enum.random(0..r)
    r*r > x*x + y*y
  end
  def round(0, _, a) do a end
  def round(k, r, a) do
    if dart(r) do
      round(k-1, r, a+1)
    else
      round(k-1, r, a)
    end
  end

  # k amount of rounds total
  # j amount of thrown darts per round
  # r is the radius of the circle thrown at
  def rounds(k, j, r) do
    rounds(k, j, 0, r, 0)
    end
  def rounds(0, _, t, _, a) do a / t end
  def rounds(k, j, t, r, a) do
    a = round(j, r, a)
    t = (t+j)
    pi = (4 * a / t)
    :io.format("Our pi:~14.10f,  Diff =~14.10f\n", [pi, (pi - :math.pi())])
    rounds(k-1, j, t, r, a)
    end
end
