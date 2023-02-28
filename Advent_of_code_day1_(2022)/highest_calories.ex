defmodule Calorie do
  # ADVENT OF CODE DAY 1 (2022)
  # Find the elf holding food with most calories
  # Find sum of top 3 elves with calorie

  def highest_calorie(path, flag) do
    case File.read(path) do
    {:ok, string_list} ->
      case flag do
        :highest -> find_highest_calorie(String.split(string_list,"\r\n\r\n"), 0)
        :top3sum -> sum_of_top3((String.split(string_list,"\r\n\r\n")))
      end
    {:error, _} -> exit(:cannot_read_file)
    end
  end

  def find_highest_calorie([last], highest) do
    # Make new list without newlines
    list_with_strings =
      String.split(last, "\r\n")

    # Make new list without the lineender "" from list_with_strings
    list_with_strings_without_lineender =
      List.delete(list_with_strings, "")

    # Make new list with translated strings into integers
    list_with_integers_without_lineender =
      Enum.map(list_with_strings_without_lineender, fn(x) -> String.to_integer(x) end)

    # Generate total calories from elves
    total_current_calories =
      sum(list_with_integers_without_lineender)

    # Final evaluation
    if(total_current_calories > highest) do
      total_current_calories
    else
      highest
    end
  end
  def find_highest_calorie([first_calories|rest_calories], highest) do
    # Find the sum of all calories one elf carries by
    # 1. spliting the first_calories into a separate list
    # 2. translate each string to integer with the Enum.map function
    # 3. Sum the total amount of calories
    total_current_calories = sum(Enum.map(String.split(first_calories, "\r\n"), fn(x) -> String.to_integer(x) end))
    if(total_current_calories > highest) do
      find_highest_calorie(rest_calories, total_current_calories)
    else
      find_highest_calorie(rest_calories, highest)
    end
  end

  # Prepares data by creating a list of the summed up calories from each elf as an list of integers
  def top3_prep([last]) do
    list_without_lineender = List.delete(String.split(last, "\r\n"), "")
    list_with_integers = Enum.map(list_without_lineender, fn x -> String.to_integer(x) end)
    [sum(list_with_integers)]
  end
  def top3_prep([first_calories|rest]) do
    list_with_integers = Enum.map(String.split(first_calories, "\r\n"), fn x -> String.to_integer(x) end)
    [sum(list_with_integers)] ++ top3_prep(rest)
  end

  # sum_of_top3/1
  # sum 3 of elves with most calories, in case the highest one dies (or something)
  def sum_of_top3(list) do
    # Prepare list
    prepared_list = top3_prep(list)

    # Start to quicksort using last element of the prepared_list as pivot
    [first, second, third | _] = sort(prepared_list)
    first + second + third
  end
  # sum_of_top3/3
  # sort and sum last 3 values
  def sort(list) do sort(list, []) end
  def sort([], acc) do Enum.reverse(acc) end
  def sort(list, acc) do
    big_num = list_highest_num(list)
    sort(List.delete(list, big_num), [big_num|acc])
  end
  def list_highest_num(list) do list_highest_num(list, 0) end
  def list_highest_num([], num) do num end
  def list_highest_num([head|tail], num) do
    if(num < head) do
      list_highest_num(tail, head)
    else
      list_highest_num(tail, num)
    end
  end

  def sum(list) do Enum.reduce(list, 0, fn x, acc -> x + acc end) end
end
