require 'unlisp/lexer'

module Unlisp
  module Parser
    def eval_map lst
      lst.map do |x|
        if x.list?
          x = list_eval x.value
        else
          x
        end
      end
    end

    def apply lst, env
      if lst[0].atom?
        case lst[0].value
        when "fn"
        when "do"
          lst.shift
          last_line = nil
          lst.each {|x| last_line, env = apply(x.value, env) }
          return last_line, env
        else
          return (list_eval lst), env
        end
      end
    end

    def list_eval lst
      if lst[0].atom?
        case lst[0].value
        when "+"
          Token.new(Unlisp::Token::INTEGER, plus(lst))
        when "println"
          lst.shift
          puts eval_map(lst, env).map {|x| x.print}
        when "'"
          lst.shift
          Token.new(Unlisp::Token::LIST, lst)
        when "head"
          lst[1].value[1]
        when "tail"
          lst[1].value.shift
          lst[1]
        end
      end
    end

    def plus lst
      lst.shift
      lst = eval_map lst
      lst.reduce {|x, y| x.value + y.value}
    end
  end

  module Parser
    extend self
  end
end
