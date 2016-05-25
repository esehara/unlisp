require "unlisp/version"
require "unlisp/lexer"
require "unlisp/token"
require "unlisp/parser"
require "unlisp/env"

module Unlisp
  class Machine
    def initialize
      @env = Env.new
    end

    def machine_eval l
      lst = Unlisp::Lexer::list_analyzer l
      psr = Unlisp::Parser::list_eval lst @env
    end
  end
end
