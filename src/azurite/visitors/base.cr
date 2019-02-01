module Azurite
  module Visitors
    abstract class Base
      abstract def execute(ast : Ast::Base)
    end
  end
end
