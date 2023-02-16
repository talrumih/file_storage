class Blob < ApplicationRecord
    enum storage_type: [:local, :aws, :db]
    attribute  :data, :string
    validates :uuid, presence: true, uniqueness: true
    validate :decode
    validate :get_file_size
    validate  :add_to_db
    private
    def decode
        return Base64.decode64(data) || self.errors.add(:data, "Cannot Decode") 
    end
   
    def add_to_db
        if uuid && self.storage_type == "local"
            File.open(Rails.root.join("public",uuid+get_ext), 'wb') do |f|
                f.write(decode)
            end
        elsif uuid && self.storage_type == "db"
            BlobDb.create!(uuid: uuid, data: data)
        elsif uuid && self.storage_type == "aws"
            blob_aws = BlobAws.new(key: uuid+get_ext, data: decode, content_type: content_type)
            blob_aws.create_request("PUT")
        else
            self.errors.add(:storage_type, "Only Local")
        end
    end
    def data
        if !self[:data] && self.storage_type == "local"
            if File.exists?(Rails.root.join("public", uuid+(ext||'')))
                decoded = File.open(Rails.root.join("public", uuid+(ext||''))).read
                self[:data] = Base64.encode64(decoded)
            end
        elsif !self[:data] && self.storage_type == "db"
            self[:data] = BlobDb.find_by_uuid(uuid).data
        elsif !self[:data] && self.storage_type == "aws"
            blob_aws = BlobAws.new(key: uuid+(ext||''), data: "", content_type: content_type)
            self[:data] = Base64.encode64(blob_aws.create_request("GET"))
        else
            self[:data]
        end
    end
    def get_mime_type
        type = Marcel::MimeType.for StringIO.new(decode)
        self[:content_type] = type
        type
    end
    def get_ext
        type = get_mime_type
        if type == "application/octet-stream"
            ext = ''
        else
            ext = Rack::Mime::MIME_TYPES.invert[type]
        end
        self[:ext] = ext
        ext
    end
    def get_file_size
        file = Tempfile.new(uuid)
        file.binmode
        file.write(decode)
        file.rewind
        self[:filesize] = file.size
        file.close
        file.unlink
    end
end
