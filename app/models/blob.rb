class Blob < ApplicationRecord
    enum storage_type: [:local, :aws, :db]
    attribute  :data, :string
    validates :uuid, presence: true, uniqueness: true
    validate  :add_to_db
    private
    def add_to_db
        if uuid && self.storage_type == "local"
            File.open(Rails.root.join("public",uuid), 'wb') do |f|
                f.write(Base64.decode64(data))
            end
        else
            self.errors.add(:storage_type, "Only Local")
        end
    end
    def data
        if !self[:data] && self.storage_type == "local"
            decoded = File.open(Rails.root.join("public", uuid)).read
            self[:data] = Base64.encode64(decoded)
        end
    end
end
