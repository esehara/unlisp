require "unlisp/version"
require "unlisp/lexer"
require "unlisp/token"
require "unlisp/parser"

module Unlisp
  class Machine
    def toplevel_eval l
      lst = Unlisp::Lexer::list_analyzer l
      psr = Unlisp::Parser::list_eval lst
    end
  end
end
