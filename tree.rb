class Tree
  attr_reader :root

  def initialize (root)
    @root = root
  end

  def to_s
    @root.to_s
  end

  def each_branch (&block)
    iterate_branches(@root) { |b| block.call b }
  end

  def iterate_branches (node, &block)
    if node.has_children? then
      for child in node.children
        iterate_branches(child) {|b| block.call b}
      end
    else
      block.call TreeBranch.new(node)
    end
  end
end

class TreeItem
  attr_reader :children, :parent, :data

  def initialize (data, parent = nil)
    @children = []
    @data = data
    @parent = parent
  end

  def has_children?
    @children.length > 0
  end

  def cut
    tail = self
    while tail != nil and tail.children.length == 0
      tail_parent = tail.parent
      if tail_parent != nil then
        tail_parent.delete_child tail
      end
      tail = tail_parent
    end
  end

  def add_child (data)
    child = TreeItem.new(data, self)
    @children.push child
    child
  end

  def delete_child(node)
    @children.delete node
  end

  def branch
    TreeBranch.new(self)
  end

  def to_s
    branch_str = ''
    if @children.length == 0 then
      count = 0
      TreeBranch.new(self).each do |node|
        branch_str = node.data.to_s + " -> " + branch_str
        count = count + 1
      end
      branch_str = branch_str + "\n"
      branch_str = '' if count <=4
    else
      for child in children
        child_str = child.to_s
        branch_str = branch_str + child_str if child_str != ''
      end
    end
    branch_str
  end
end

class TreeBranch
  include Enumerable
  attr_reader :tail_node
  attr_reader :head_node

  def initialize(tail_node)
    @tail_node = tail_node
    each {|node| @head_node = node}
  end

  def each (&block)
    node = @tail_node
    while node != nil
      block.call node
      node = node.parent
    end
  end

  def to_s
    @head_node.to_s
  end

end

class TreeBranchPathLookup
  def self.has_path?(branch)
    hash = {}
    branch.each do |node|
      return true if hash.has_key? node.data
      hash[node.data] = true
    end
    false
  end
end
