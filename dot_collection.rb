class DotCollection
  include Enumerable

  def initialize(*params)
    @dots = {}
    if (params.length == 1 and params[0].class == Array)
      params[0].each {|d| @dots[d] = d}
    end
  end

  def each (&block)
    @dots.keys.each(&block)
  end

  def add (dot)
    @dots[dot] = dot
  end

  def contains? (dot)
    @dots.has_key? dot
  end

  def delete (dot)
    @dots.delete dot
  end

  def clone
    @dots.keys.clone
  end

  def length
    @dots.length
  end

  def last
    self[self.length - 1]
  end

  def first
    self[0]
  end

  def [](index)
    @dots.keys[index]
  end

  def to_s
    "#{super} #{@dots.keys.to_s}"
  end
end