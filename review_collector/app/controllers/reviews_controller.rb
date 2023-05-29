require 'httparty'
require 'nokogiri'

class ReviewsController < ApplicationController
    VALID_LENDER_TYPES = ['mortgage', 'personal', 'business', 'student', 'automotive', 'credit repair', 'debt relief', 'investment'].freeze
    INVALID_LENDER_TYPE_MESSAGE = "Invalid lender type"

    def lendingtree
        if valid_lender_type?
            reviews = LendingtreeService.collect_reviews(params[:lender_type], params[:lender_name], params[:lender_id])
            render json: { reviews: reviews }
        else
            render json: { error: INVALID_LENDER_TYPE_MESSAGE }, status: :unprocessable_entity
        end
    rescue LendingtreeService::ParsingError => e
        render json: { error: e.message }, status: :internal_server_error
    rescue LendingtreeService::ReviewCollectionError => e
        render json: { error: e.message }, status: :internal_server_error
    end

    def lendingtree_form
        if present_params?
            unless valid_lender_type?
                flash[:error] = INVALID_LENDER_TYPE_MESSAGE
                redirect_to reviews_lendingtree_path
                return
            end

            @reviews = LendingtreeService.collect_reviews(params[:lender_type], params[:lender_name], params[:lender_id])
        end
    rescue LendingtreeService::ParsingError, LendingtreeService::ReviewCollectionError, StandardError => e
        flash[:error] = e.message
        redirect_to reviews_lendingtree_path
        return
    end

    private

    def present_params?
        lender_type = params[:lender_type]
        lender_name = params[:lender_name]
        lender_id = params[:lender_id]

        lender_type.present? && lender_name.present? && lender_id.present?
    end

    def valid_lender_type?
        lender_type = params[:lender_type]&.downcase

        VALID_LENDER_TYPES.include?(lender_type)
    end
end
