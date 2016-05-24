require 'unlisp/token'
module Unlisp
  module Lexer
    def tokenize str
      return Token.new(Token::LIST, str) if str.is_a? Array
      case str
      when /\d+/
        Token.new(Token::INTEGER, str.to_i)
      when /"(.+)"/
        Token.new(Token::STRING, $1)
      when /(\D.*)/
        Token.new(Token::ATOM, $1)
      else
        Token.new(Token::ERROR, str)
      end
    end

    def list_analyzer lst
      parse_result = []
      while !lst.empty?
        token = tokenize(lst.shift)
        if token.list?
          token.value = list_analyzer(token.value)
        end
        parse_result << token
      end
      parse_result
    end
  end

  module Lexer
    extend self
  end
end
