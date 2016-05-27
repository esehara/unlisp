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

    def top_env! val
      atom, value = val
      env_find = @env.find_all {|x| atom.value == x[0].value}
      return env! val if env_find.empty?
      env_find[-1][1] = value
    end

    def next val
      newenv = self.clone
      newenv.reset! @env.clone
      newenv.env! val
      return newenv
    end

    def get atom
      env_find = @env.find_all {|x| atom.value == x[0].value}
      raise "Not found value: #{atom}" if env_find.empty?
      return env_find[-1][1]
    end
  end
end
