require "../spec_helper"

# class UserModel < Azurite::Entity
#   attribute name : String
#   attribute foo : Int32
# end

# class UserRepo < Azurite::Query(UserModel)
# end

module Foo
  class User < Azurite::Entity
    attribute age : Float64
    attribute name : String
  end

  class Users < Azurite::Repository(User)
    collection "users"
  end

  class Content < Azurite::Entity
    attribute name : String
    attribute items : Array(String)
  end

  class Contents < Azurite::Repository(Content)
    collection "content"
  end
end

describe Azurite::Entity do
  it "debug" do
    # pp "debug"
    # pp UserModel.attributes
    # repo = Azurite::Repository.new("mongodb://localhost:27017", "test")
    # pp UserRepo.new(repo).builder

    pp Foo::User.attributes
    # pp Foo::User.builder.new

    db = Azurite::Database.new("mongodb://localhost:27017", "test")
    repo = Foo::Users.new(db)
    # pp repo
    # pp repo.builder

    # repo.where {
    #   age { eq(19) }
    # }

    # pp repo.exec

    # repo2 = Foo::Contents.new(db)
    # repo2.where {
    #   name { eq("Prem") }
    # }

    # pp repo2.exec

    new_one = Foo::User.new({
      "name" => "Kelly",
      "age" => 25f64
    })

    pp new_one

    repo.insert([
      new_one
    ])
  end
end
