DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class Images
    include DataMapper::Resource
    property :id, Serial
    property :image_hash, Text, :required => true, :unique => true
    property :status, Integer, :required => true
end

DataMapper.auto_upgrade!
