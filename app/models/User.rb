class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true
    validates :company_name, presence: true
    validates :email, uniqueness: true
    validates :company_name, uniqueness: true

    def create_ota_code
        ota_string = ""
        6.times do |i|
            random_number = rand(10)
            ota_string += random_number.to_str
        end
        self.update(ota_code: ota_string)
    end

end