require 'unlisp/lexer'

module Unlisp
  module Parser

    def apply lst
      lst.map do |x|
        if x.list?
          x = list_eval x.value
        else
          x
        end
      end
    end

    def list_eval lst
      if lst[0].type == Unlisp::Token::ATOM
        case lst[0].value
        when "+"
          Token.new(Unlisp::Token::INTEGER, plus(lst))
        when "print"
          lst.shift
          lst = apply lst
          puts lst.value
        end
      end
    end

    def plus lst
      lst.shift
      lst = apply lst
      lst.reduce {|x, y| x.value + y.value}
    end
  end

  module Parser
    extend self
  end
end
