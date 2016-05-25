module Unlisp
  class Env
    def initialize
      @env = []
    end

    def env! newdef
      @env << newdef
    end

    def reset! env
      @env = env
    end

    def pop!
      @env.pop
    end

    def next val
      env! val
      newenv = self.clone
      newenv.reset! @env.clone
      return newenv
    end

    def get atom
      @env.find_all {|x| atom.value == x[0].value}[-1][1]
    end
  end
end
