module Unlisp
  class Env
    def initialize
      @env = []
    end

    def env! newdef
      @env << newdef
    end
  end
end
