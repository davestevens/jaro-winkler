#!/usr/bin/env ruby


# http://www.cs.cmu.edu/~radar/dmg/MCALL/lingpipe-3.6.0/docs/api/index.html
# http://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance

class Fuzzy
  def initialize(possible)
    @possible = [possible].flatten || []
  end

  def closest_match(string)
    m = []
    @possible.each do |str|
      m.push proximity(string, str)
    end

    @possible[ m.each_with_index.max[1] ]
  end

  private

  # Jaro Winkler Proximity Function
  def proximity(string1, string2)
    len1 = string1.length
    len2 = string2.length

    if len1 == 0
      if len2 == 0
        return 1.0
      else
        return 0.0
      end
    end

    search_range = [0, [len1, len2].max/2 - 1].max

    matched1 = [].fill(false, 0...len1)
    matched2 = [].fill(false, 0...len2)

    num_common = 0
    for i in 0...len1
      _start = [0, i-search_range].max
      _end = [i+search_range+1, len2].min

      for j in _start..._end
        next if matched2[j]
        next if string1[i] != string2[j]

        matched1[i] = true
        matched2[j] = true

        num_common += 1
        break
      end
    end

    return 0.0 if num_common == 0

    num_half_transposed = 0
    j = 0
    for i in 0...len1
      next if !matched1[i]
      j += 1 while !matched2[j]

      num_half_transposed += 1 if string1[i] != string2[j]

      j += 1
    end

    num_transposed = num_half_transposed / 2

    a = Float(num_common) / len1
    b = Float(num_common) / len2
    c = (num_common - num_transposed) / Float(num_common)

    weight = (a + b + c) / 3.0

    return weight if weight <= weight_threshold

    max = [num_chars, [len1, len2].min].min
    pos = 0

    pos += 1 while pos < max and string1[pos] == string2[pos]

    return weight if pos == 0
    return weight + 0.1 * pos * (1.0 - weight)

  end

  def weight_threshold
    0.7
  end

  def num_chars
    4
  end

end

f = Fuzzy.new(["projects", "tracker", "responses", "/"])

puts f.closest_match("proect/")
puts f.closest_match("traker")
puts f.closest_match("res")
puts f.closest_match("")

#puts f.proximity("AL", "AL")
#puts f.proximity("MARTHA", "MARHTA")
#puts f.proximity("JONES", "JOHNSON")
#puts f.proximity("ABCVWXYZ", "CABVWXYZ")
