class User < ApplicationRecord
    has_secure_token :token
end
