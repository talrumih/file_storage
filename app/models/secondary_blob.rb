class SecondaryBlob < ApplicationRecord
    self.abstract_class = true
    db = YAML.load_file("#{Rails.root}/config/database.yml")
    connects_to database: { writing: db["development"]["blobs"], reading: db["development"]["blobs"] }
end