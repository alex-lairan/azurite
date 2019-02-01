module Azurite
  module Ast
    class Base
      @children = Array(Base).new

      def add(item)
        @children << item
      end
    end
  end
end
