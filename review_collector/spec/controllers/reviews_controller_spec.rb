require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
    let(:lender_type) { 'business' }
    let(:lender_name) { 'not-ondeck' }
    let(:lender_id) { '123' }

    #  ideally would use factories such as Factory Bot
    let(:review1) { Review.new(lender_id, "Title", "Good service", "Mike", "4", Date.new(2023, 04, 01), true, true) }
    let(:review2) { Review.new(lender_id, "Title", "Great service", "Jim", "5", Date.new(2023, 05, 01), true, true) }

    let(:valid_params) { { lender_type: lender_type, lender_name: lender_name, lender_id: lender_id } }
    let(:invalid_params) { { lender_type: 'invalid', lender_name: lender_name, lender_id: lender_id } }
    let(:missing_params) { { lender_type: lender_type, lender_name: nil, lender_id: lender_id } }

    describe 'GET #lendingtree' do
        context 'with valid params' do
            it 'returns OK status' do
                reviews = [review1, review2]

                expect(LendingtreeService).to receive(:collect_reviews).with(lender_type, lender_name, lender_id).and_return(reviews)

                get :lendingtree, params: valid_params

                expect(response).to have_http_status(:ok)
            end

            it 'returns the reviews' do
                reviews = [review1, review2]

                expect(LendingtreeService).to receive(:collect_reviews).with(lender_type, lender_name, lender_id).and_return(reviews)

                get :lendingtree, params: valid_params

                reviews_json = JSON.parse(response.body)['reviews']

                expect(reviews_json).to be_an(Array)
                expect(reviews_json.count).to eq(reviews.count)

                reviews_json.each_with_index do |json_review, index|
                    expected_review = reviews[index]

                    expect(json_review['lender_id']).to eq(expected_review.lender_id)
                    expect(json_review['title']).to eq(expected_review.title)
                    expect(json_review['content']).to eq(expected_review.content)
                    expect(json_review['author']).to eq(expected_review.author)
                    expect(json_review['star_rating']).to eq(expected_review.star_rating)
                    expect(json_review['date']).to eq(expected_review.date.to_s)
                    expect(json_review['recommended']).to eq(expected_review.recommended)
                    expect(json_review['closed_with_lender']).to eq(expected_review.closed_with_lender)
                  end
            end
        end

        context 'with invalid lender type' do
            it 'returns an error' do
                get :lendingtree, params: invalid_params

                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['error']).to eq(ReviewsController::INVALID_LENDER_TYPE_MESSAGE)
            end
        end
    end

    describe 'GET #lendingtree_form' do
        context 'with valid params' do
            it 'sets @reviews var' do
                reviews = [review1, review2]

                expect(LendingtreeService).to receive(:collect_reviews).with(lender_type, lender_name, lender_id).and_return(reviews)

                get :lendingtree_form, params: valid_params

                expect(assigns(:reviews)).to eq(reviews)
            end
        end

        context 'with invalid lender type' do
            it 'sets flash error' do
                get :lendingtree_form, params: invalid_params

                expect(flash[:error]).to eq(ReviewsController::INVALID_LENDER_TYPE_MESSAGE)
            end

            it 'redirects' do
                get :lendingtree_form, params: invalid_params

                expect(response).to redirect_to(reviews_lendingtree_path)
            end
        end

        context 'with missing params' do
            it 'does not set @reviews var' do
                get :lendingtree_form, params: missing_params

                expect(assigns(:reviews)).to be_nil
                expect(response).to have_http_status(:ok)
            end
        end
    end
end
