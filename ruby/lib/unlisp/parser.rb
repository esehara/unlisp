require 'unlisp/lexer'

module Unlisp
  module Parser
    def eval_map(lst, env)
      lst.map do |x|
        if x.list?
          x, _ = list_eval(x.value, env)
          x
        elsif x.integer?
          x
        else
          env.get x
        end
      end
    end

    def next_val lst
      if lst[1].list?
        next_value, _ = list_eval(lst[1].value, lst[0].env)
      else
        next_value = lst[1]
      end
      return next_value
    end

    def call lst, env
      raise "Wrong number of argument" if lst[1].nil?
      raise "Not found value: #{lst[1]}" if next_val(lst).nil?
      head = lst[0]
      head.env = head.env.next [head.value[0], next_val(lst)]
      if head.value[1].list?
        result_lst, _ = list_eval(head.value[1], head.env)
      elsif head.value[1].atom?
        result_lst, _ = apply_atom(head.value[1], head.value, head.env)
      end
      return result_lst, env
    end

    def eval_if atom, lst, env
      lst = lst.clone
      raise "Syntax Error: if" if lst[2].nil? || lst[3].nil?
      lst[1], _ = list_eval(lst[1], env)
      if lst[1].true?
        if lst[2].list? || lst[2].function?
          lst[2], _ = list_eval(lst[2], env)
        elsif lst[2].atom?
          return apply_atom(lst[2], lst[2], env)
        end
        return lst[2], env
      else
        if lst[3].list? || lst[3].function?
          lst[3], _ = list_eval(lst[3], env)
        elsif lst[3].atom?
          return apply_atom(lst[3], lst[3], env)
        end
        return lst[3], env
      end
    end

    def user_def atom, lst, env
      if atom.atom?
        atom = env.get(atom)
        return atom, env if atom.integer?
      end
      lst[0] = atom
      raise "Not found value: #{lst[0]}" if lst[0].nil?
      if lst[0].function?
        if lst[1].list?
          lst[1], _ = list_eval(lst[1], env)
        end
      end
      return list_eval(lst, env)
    end

    def apply_atom atom, lst, env
      lst = lst.clone
      case atom.value
      when "if"
        return eval_if atom, lst, env
      when "<"
        fst, snd = eval_map([lst[1], lst[2]], env)
        return fst.value < snd.value ? Token.true : Token.false, env
      when "def"
        env.top_env! [lst[1], lst[2]]
        return lst, env
      when "fn"
        raise "Syntax Error: fn" if lst[1].nil? || lst[2].nil?
        fn = Token.new(Unlisp::Token::FUNCTION, [lst[1], lst[2]])
        fn.env! env
        return fn, env
      when "do"
        lst = lst.clone
        lst.shift
        last_line = nil
        lst.each {|x| last_line, env = list_eval(x.value, env) }
        return last_line, env
      when "+"
        return plus(lst, env), env
      when "-"
        return minus(lst, env), env
      when "="
        fst, snd = eval_map([lst[1], lst[2]], env)
        return fst.value == snd.value ? Token.true : Token.false, env
      when "println"
        lst = lst.clone
        lst.shift
        puts eval_map(lst, env).map {|x| x.print}
        return nil, env
      when "'"
        lst = lst.clone
        lst.shift
        return Token.new(Unlisp::Token::LIST, lst), env
      when "head"
        return lst[1].value[1], env
      when "tail"
        lst[1] = lst[1].clone
        lst[1].value.shift
        return lst[1], env
      else
        return user_def atom, lst, env
      end
    end

    def list_eval lst, env
      if !lst.is_a?(Unlisp::Token) && lst[0].list?
        lst[0], _ = list_eval(lst[0].value, env)
      end
      if lst.is_a?(Unlisp::Token) && lst.list?
        return list_eval(lst.value, env)
      elsif lst[0].atom?
        return apply_atom(lst[0], lst, env)
      elsif lst[0].function?
        return call(lst, env)
      end
    end

    def minus lst, env
      lst = lst.clone
      lst.shift
      lst = eval_map(lst, env)
      lst.reduce do |x, y|
        x, _ = list_eval(x, env) if x.list?
        y, _ = list_eval(y, env) if y.list?
        Token.new(Unlisp::Token::INTEGER, x.value - y.value)
      end
    end

    def plus lst, env
      lst = lst.clone
      lst.shift
      lst = eval_map(lst, env)
      lst.reduce do |x, y|
        x, _ = list_eval(x, env) if x.list?
        y, _ = list_eval(y, env) if y.list?
        Token.new(Unlisp::Token::INTEGER, x.value + y.value)
      end
    end
  end

  module Parser
    extend self
  end
end
