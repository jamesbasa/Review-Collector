require 'httparty'
require 'nokogiri'

class ReviewsController < ApplicationController
    VALID_LENDER_TYPES = ['mortgage', 'personal', 'business', 'student', 'automotive', 'credit repair', 'debt relief', 'investment'].freeze

    def lendingtree
        # TODO - more error handling
        # TODO - add pagination params?

        if valid_params?
            collect_lendingtree_reviews(params[:lender_type], params[:lender_name], params[:lender_id])
        else
            render json: { error: "Invalid parameters" }, status: :unprocessable_entity
        end
    end

    def lendingtree_form
        if valid_params?
            @reviews = collect_lendingtree_reviews(lender_type, lender_name, lender_id)
        else
            flash[:error] = "Invalid parameters"
            redirect_to reviews_lendingtree_path
        end
    end

    private

    def valid_params?
        lender_type = params[:lender_type]&.downcase
        lender_name = params[:lender_name]
        lender_id = params[:lender_id]

        lender_type.present? && lender_name.present? && lender_id.present? && VALID_LENDER_TYPES.include?(lender_type)
    end

    def collect_lendingtree_reviews(lender_type, lender_name, lender_id)
        reviews = []
        page = 1
 
        while true
            # TODO make this prefix a constant
            url = "https://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_id}?sort=&pid=#{page}"
            response = HTTParty.get(url)
            doc = Nokogiri::HTML(response.body)
            review_nodes = doc.css('.mainReviews')

            break if review_nodes.empty?

            review_nodes.each do |review|
                title = review.at_css('p.reviewTitle')&.text
                content = review.at_css('p.reviewText')&.text
                author = review.at_css('p.consumerName')&.text
                star_rating_text = review.at_css('div.numRec')&.text
                star_rating = star_rating_text&.match(/(\d+) of \d+/)&.captures&.first&.to_i
                date_text = review.at_css('p.consumerReviewDate')&.text
                date = Date.strptime(date_text, 'Reviewed in %B %Y') if date_text
                recommended = review.at_css('div.lenderRec')&.text == "Recommended"
                closed_with_lender = review.at_css('div.reviewPoints li:has(p:contains("Closed with Lender")) div')&.text == "Yes"
        
                reviews << Review.new(title, content, author, star_rating, date, recommended, closed_with_lender)
            end

            page += 1
        end

        reviews
    end
end
