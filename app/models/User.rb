class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true
    validates :company_name, presence: true
end