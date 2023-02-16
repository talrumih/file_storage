class BlobAws
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    require 'digest'
    require 'openssl'
    attr_accessor :key, :data, :content_type

    validates :key, :data, :presence => true

    def initialize(attributes = {})
        attributes.each do |name, value|
            send("#{name}=", value)
        end
    end
    def persisted?
        false
    end
    def create_request(method)
        aws = Rails.application.credentials.aws
        require "uri"
        require "net/http"

        url = URI("https://#{aws[:host]}/#{key}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        t = Time.now.utc
        amz_date = t.strftime('%Y%m%dT%H%M%SZ')
        date_stamp = t.strftime('%Y%m%d')
        host = aws[:host]
        access_key = aws[:access_key]
        secret_key = aws[:secret_key]
        regionName = aws[:regionName]
        serviceName = aws[:serviceName]
        canonical_headers = "content-type:#{content_type}\nhost:#{host}\nx-amz-content-sha256:#{data_sha256}\nx-amz-date:#{amz_date}"
        signed_headers = "content-type;host;x-amz-content-sha256;x-amz-date"
        canonical_request = [method, "/#{key}", '', canonical_headers, '',
            signed_headers, data_sha256].join("\n")
        hashed_canonical_request =  OpenSSL::Digest.new("sha256").hexdigest(canonical_request)
        credential_scope = [date_stamp, regionName, serviceName, 'aws4_request'].join("/")
        string_to_sign = [
            "AWS4-HMAC-SHA256", amz_date, credential_scope,
            hashed_canonical_request
          ].join("\n")
        signing_key = getSignatureKey(secret_key, date_stamp, regionName, serviceName)
        signature = OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign)
        if method == "GET"
            request = Net::HTTP::Get.new(url)
        else
            request = Net::HTTP::Put.new(url)
        end
        request["x-amz-content-sha256"] = data_sha256
        request["x-amz-date"] = amz_date
        request["Authorization"] = "AWS4-HMAC-SHA256 Credential=#{access_key}/#{date_stamp}/#{regionName}/#{serviceName}/aws4_request, SignedHeaders=#{signed_headers}, Signature=#{signature}"
        request["Content-Type"] = content_type
        request["host"] = host
        request.body = data

        response = https.request(request)
        response.read_body
    end

    private
    def data_sha256
        OpenSSL::Digest.new("sha256").hexdigest(data)
    end
   
    
    def getSignatureKey(key, dateStamp, regionName, serviceName)
        date    = OpenSSL::HMAC.digest('sha256', "AWS4" + key, dateStamp)
        region  = OpenSSL::HMAC.digest('sha256', date, regionName)
        service = OpenSSL::HMAC.digest('sha256', region, serviceName)
        signature = OpenSSL::HMAC.digest('sha256', service, "aws4_request")
        signature
    end
end