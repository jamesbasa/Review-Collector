require 'httparty'
require 'nokogiri'

class ReviewsController < ApplicationController
    VALID_LENDER_TYPES = ['mortgage', 'personal', 'business', 'student', 'automotive', 'credit repair', 'debt relief', 'investment'].freeze

    def lendingtree
        # TODO - more error handling
        # TODO - add pagination params?
        if present_params? && valid_lender_type?
            reviews = LendingtreeService.collect_reviews(params[:lender_type], params[:lender_name], params[:lender_id])
            render json: { reviews: reviews }
        else
            render json: { error: "Invalid parameters" }, status: :unprocessable_entity
        end
    end

    def lendingtree_form
        if present_params?
            unless valid_lender_type?
                flash[:error] = "Invalid lender type"
                redirect_to reviews_lendingtree_path
                return
            end

            @reviews = LendingtreeService.collect_reviews(params[:lender_type], params[:lender_name], params[:lender_id])
        end
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
