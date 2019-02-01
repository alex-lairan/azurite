require "mongo"

module Azurite
  class Repository
    getter client : Mongo::Client
    getter database : Mongo::Database


    def initialize(db_url, db_name)
      @client = Mongo::Client.new db_url
      @database = @client[db_name]
    end
  end
end

# require "mongo"
# class Mongo::ORM::Adapter
  # property client : Mongo::Client
  # property database : Mongo::Database
#   property database_name : String
#   DATABASE_YML = "config/database.yml"

#   def initialize
#     database_url : String = "mongodb://localhost:27017"
#     database_name : String = "mongo_orm_db"
#     if ENV["DATABASE_URL"]?
#       database_url = ENV["DATABASE_URL"]
#       database_name = ENV["DATABASE_NAME"] if ENV["DATABASE_NAME"]
#     elsif File.exists?(DATABASE_YML)
#       yaml = YAML.parse(File.read DATABASE_YML)
#       database_url = yaml["database_url"].to_s if yaml["database_url"]?
#       database_name = yaml["database_name"].to_s if yaml["database_name"]?
#     end
#     @client = Mongo::Client.new database_url
#     database_name = ENV["DATABASE_NAME"] if ENV["DATABASE_NAME"]?
#     @database = @client[database_name]
#     @database_name = database_name
#   end
# end
