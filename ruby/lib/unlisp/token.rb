module Unlisp
  class Token < Struct.new(:type, :value)
    # Token types
    INTEGER  = 1
    STRING   = 2
    ATOM     = 3
    LIST     = 4
    ERROR    = 5

    def list?
      type == LIST
    end
  end
end
