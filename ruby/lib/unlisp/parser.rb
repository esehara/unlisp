require 'unlisp/lexer'

module Unlisp
  module Parser
    def list_eval lst
      if lst[0].type == Unlisp::Token::ATOM
        case lst[0].value
        when "+"
          Token.new(Unlisp::Token::INTEGER, plus(lst))
        end
      end
    end

    def plus lst
      lst.shift
      lst.reduce do |x, y|
        x, y = [x, y].map do |z|
          if z.type == Unlisp::Token::LIST
            z = list_eval z.value
          else
            z
          end
        end
        x.value + y.value
      end
    end
  end

  module Parser
    extend self
  end
end
