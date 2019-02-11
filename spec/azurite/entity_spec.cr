require "../spec_helper"

# class UserModel < Azurite::Entity
#   attribute name : String
#   attribute foo : Int32
# end

# class UserRepo < Azurite::Query(UserModel)
# end

module Foo
  class User < Azurite::Entity
    attribute age : Int32
    attribute name : String
  end

  class Users < Azurite::Repository(User)
  end
end

describe Azurite::Entity do
  it "debug" do
    # pp "debug"
    # pp UserModel.attributes
    # repo = Azurite::Repository.new("mongodb://localhost:27017", "test")
    # pp UserRepo.new(repo).builder

    pp Foo::User.attributes
    pp Foo::User.builder.new

    db = Azurite::Database.new("mongodb://localhost:27017", "test")
    repo = Foo::Users.new(db)
    pp repo
    pp repo.builder

    repo.where {
      age { gt(5) & lt(100) } & name { gt(5) }
    }

    pp repo.builder
  end
end
