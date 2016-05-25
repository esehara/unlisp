require 'unlisp/lexer'

module Unlisp
  module Parser
    def eval_map(lst, env)
      lst.map do |x|
        if x.list?
          x = list_eval(x.value, env)
        elsif x.integer?
          x
        else
          env.get x
        end
      end
    end

    def list_eval lst, env
      if lst[0].atom?
        case lst[0].value
        when "def"
          env.env! [lst[1], lst[2]]
          return lst, env
        when "do"
          lst.shift
          last_line = nil
          lst.each {|x| last_line, env = list_eval(x.value, env) }
          return last_line, env
        when "+"
          Token.new(Unlisp::Token::INTEGER, plus(lst, env))
        when "println"
          lst.shift
          puts eval_map(lst, env).map {|x| x.print}
        when "'"
          lst.shift
          Token.new(Unlisp::Token::LIST, lst)
        when "head"
          return lst[1].value[1], env
        when "tail"
          lst[1].value.shift
          return lst[1], env
        else
          return env.get atom, env
        end
      end
    end

    def plus lst, env
      lst.shift
      lst = eval_map(lst, env)
      lst.reduce {|x, y| x.value + y.value}
    end
  end

  module Parser
    extend self
  end
end
