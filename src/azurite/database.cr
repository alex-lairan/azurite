require "mongo"

module Azurite
  class Database
    getter client : Mongo::Client
    getter database : Mongo::Database


    def initialize(db_url, db_name)
      @client = Mongo::Client.new db_url
      @database = @client[db_name]
    end
  end
end
