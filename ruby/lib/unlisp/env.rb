module Unlisp
  class Env
    def initialize
      @env = []
    end

    def env! newdef
      @env << newdef
    end

    def get atom
      @env.find_all {|x| atom.value == x[0].value}[-1][1]
    end
  end
end
