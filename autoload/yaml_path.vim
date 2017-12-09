ruby << RUBY
gem 'psych', '>= 3.0.0'
require 'psych'

class YAMLPath
  def self.traverse(node, line, col)
    case node
    when Psych::Nodes::Mapping
      node.children.each_slice(2).find do |key, value|
        if path = traverse(value, line, col)
          break [key.value].concat(Array(path))
        end
      end
    when Psych::Nodes::Scalar
      return node.value if node.start_line <= line && line <= node.end_line &&
                           node.start_column <= col && col <= node.end_column
    else
      node.children&.each do |c|
        if path = traverse(c, line, col)
          break path
        end
      end
    end
  end

  def self.path(source, line, col)
    ast = Psych.parse(source)
    traverse(ast, line, col)
  end
end
RUBY

function! yaml_path#show() abort
  ruby << RUBY
  source = Vim.evaluate("getbufline('%', 1, '$')").join("\n")
  line = Vim.evaluate("line('.')") - 1
  col = Vim.evaluate("col('.')") - 1
  p YAMLPath.path(source, line, col)
RUBY
endfunction

