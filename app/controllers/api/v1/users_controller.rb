module Api
    module V1
      class UsersController < ApplicationController

        def generate_token
            @user = User.create!(active: true)
            render json: {status: 'SUCCESS', message: 'generated token', token: @user.token}, status: :ok
        end

      end
    end
end