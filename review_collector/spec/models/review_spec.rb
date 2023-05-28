require 'rails_helper'

RSpec.describe Review, type: :model do
    describe "#initialize" do
        let(:review) { Review.new(review_id, brand_id, title, content, author, user_location, star_rating, date, recommended) }
        let(:review_id) { "123" }
        let(:brand_id) { "321" }
        let(:title) { "Great Service" }
        let(:content) { "I liked it" }
        let(:author) { "Billy Bob" }
        let(:user_location) { "Los Angeles, CA" }
        let(:star_rating) { "4" }
        let(:date) { Date.new(2023, 2, 1) }
        let(:recommended) { true }

        it "sets the instance vars" do
            expect(review.review_id).to eq review_id
            expect(review.brand_id).to eq brand_id
            expect(review.title).to eq title
            expect(review.content).to eq content
            expect(review.author).to eq author
            expect(review.user_location).to eq user_location
            expect(review.star_rating).to eq star_rating
            expect(review.date).to eq date
            expect(review.recommended).to eq recommended
        end
    end
end
