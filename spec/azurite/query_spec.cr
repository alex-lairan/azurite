require "../spec_helper"

class User < Azurite::Entity
end

describe Azurite::Query do
  describe ".collection_name" do
    it "expect to have right collection" do
      # Azurite::Query(User).set_collection_name("users")
      # pp Azurite::Query(User).collection_name
    end
  end

  describe "#where" do
    it "test" do
      repo = Azurite::Repository.new("mongodb://localhost:27017", "test")
      query = Azurite::Query(User).new(repo)

      req = query.where {
        age { (lt(5) & gt(0)) | eq(18) }
      }

      pp req
      pp req.query

      foo = {
        "age" => {
          "$or" => [
            { "$lt" => 5, "$gt" => 0},
            { "$eq" => 18 }
          ]
        }
      }

      pp foo.class
    end
  end

  describe "#limit" do

  end

  describe "#count" do

  end

  describe "#exec" do

  end

  describe "#find" do

  end
end
