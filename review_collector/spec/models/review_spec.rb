require 'rails_helper'

RSpec.describe Review, type: :model do
    describe "#initialize" do
        let(:review) { Review.new(lender_id, title, content, author, star_rating, date, recommended, closed_with_lender) }
        let(:lender_id) { "123" }
        let(:title) { "Great Service" }
        let(:content) { "I liked it" }
        let(:author) { "Billy Bob" }
        let(:star_rating) { "4" }
        let(:date) { Date.new(2023, 2, 1) }
        let(:recommended) { true }
        let(:closed_with_lender) { false }

        it "sets the instance vars" do
            expect(review.lender_id).to eq lender_id
            expect(review.title).to eq title
            expect(review.content).to eq content
            expect(review.author).to eq author
            expect(review.star_rating).to eq star_rating
            expect(review.date).to eq date
            expect(review.recommended).to eq recommended
            expect(review.closed_with_lender).to eq closed_with_lender
        end
    end
end
