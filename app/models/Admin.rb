 class Admin < ApplicationRecord
    has_secure_password

    def verify(password)
        if self.authenticate(password)
            true
        else
            false
        end
    end

 end