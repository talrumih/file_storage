module Api
  module V1
    class BlobsController < ApplicationController
      include ActionController::HttpAuthentication::Basic::ControllerMethods
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate, except: [ :index ]

      def index
        @blobs = Blob.order('created_at DESC')
        render json: {status: 'SUCCESS', message: 'Loaded blobs', data:@blobs}, status: :ok
      end

      def show
        @blob = Blob.find_by_uuid(params[:id])
        render json: {status: 'SUCCESS', message: 'Loaded blobs', data:@blob}, status: :ok
      end

      def create
        @blob = Blob.new(blob_params)

        if @blob.save
          render json: {status: 'SUCCESS', message: 'Blob is saved', data:@blob}, status: :ok
        else
          render json: {status: 'Error', message: 'Blob is not saved', data:@blob.errors}, status: :unprocessable_entity
        end
      end

      def update
        @blob = Blob.find(params[:id])

        if @blob.update_attributes(blob_params)
          render json: {status: 'SUCCESS', message: 'Blob is updated', data:@blob}, status: :ok
        else
          render json: {status: 'Error', message: 'Blob is not updated', data:@blob.errors}, status: :unprocessable_entity
        end
      end

      def destroy
        @blob = Blob.find(params[:id])
        @blob.destroy

        render json: {status: 'SUCCESS', message: 'Blob successfully deleted', data:@blob}, status: :ok
      end

      private
      def blob_params
        params.require(:blob).permit(:uuid, :data, :storage_type)
      end
      def authenticate
        authenticate_or_request_with_http_token do |token, options|
          user_token = User.find_by(token: token, active: true)
          ActiveSupport::SecurityUtils.secure_compare(token, ((user_token.token if user_token) || ''))
        end
      end
    end
  end
end