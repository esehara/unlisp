require 'unlisp/lexer'

module Unlisp
  module Parser
    def eval_map(lst, env)
      lst.map do |x|
        if x.list?
          lst, _ = list_eval(x.value, env)
          lst
        elsif x.integer?
          x
        else
          env.get x
        end
      end
    end

    def list_eval lst, env
      if !lst.is_a?(Unlisp::Token) && lst[0].list?
        lst[0], _ = list_eval(lst[0].value, env)
      end

      if lst.is_a?(Unlisp::Token) && lst.list?
        list_eval(lst.value, env)
      elsif lst[0].function?
        next_env = env.next [lst[0].value[0], lst[1]]
        result_lst, result_env = list_eval(lst[0].value[1], next_env)
        result_env.pop!
        return result_lst, result_env
      elsif lst[0].atom?
        case lst[0].value
        when "if"
          lst[1] = list_eval(lst[1], env) if lst[1].list?
          if lst[1].true?
            lst[2] = list_eval(lst[2], env) if lst[2].list?
            lst[2]
          else
            lst[3] = list_eval(lst[3], env) if lst[3].list?
            lst[3]
          end
        when "<"
          fst, snd = eval_map([lst[1], lst[2]], env)
          fst.value < snd.value ? Token.true : Token.false
        when "def"
          env.env! [lst[1], lst[2]]
          return lst, env
        when "fn"
          return Token.new(Unlisp::Token::FUNCTION, [lst[1], lst[2]]), env
        when "do"
          lst.shift
          last_line = nil
          lst.each {|x| last_line, env = list_eval(x.value, env) }
          return last_line, env
        when "+"
          return Token.new(Unlisp::Token::INTEGER, plus(lst, env)), env
        when "println"
          lst.shift
          puts eval_map(lst, env).map {|x| x.print}
        when "'"
          lst.shift
          return Token.new(Unlisp::Token::LIST, lst), env
        when "head"
          return lst[1].value[1], env
        when "tail"
          lst[1].value.shift
          return lst[1], env
        else
          lst[0] = env.get(lst[0])
          return list_eval(lst, env)
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
