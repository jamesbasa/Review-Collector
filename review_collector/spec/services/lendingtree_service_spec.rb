require 'rails_helper'
require 'webmock/rspec'

RSpec.describe LendingtreeService do
    describe '#collect_reviews' do
        subject { LendingtreeService.collect_reviews(lender_type, lender_name, lender_id) }

        let(:lender_type) { 'business' }
        let(:lender_name) { 'not-ondeck' }
        let(:lender_id) { '123' }
        let(:url) { "https://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_id}?sort=&pid=1" }

        context 'when lender_type parameter is not provided' do
            let(:lender_type) { nil }

            it 'raises an error' do
                expect {
                    subject
                }.to raise_error(ArgumentError)
            end
        end

        context 'when lender_name parameter is not provided' do
            let(:lender_name) { nil }

            it 'raises an error' do
                expect {
                    subject
                }.to raise_error(ArgumentError)
            end
        end

        context 'when lender_id parameter is not provided' do
            let(:lender_id) { nil }

            it 'raises an error' do
                expect {
                    subject
                }.to raise_error(ArgumentError)
            end
        end

        context 'when there are no reviews' do
            it 'returns an empty array' do
                response_body = File.read('spec/fixtures/lendingtree_no_reviews.html')

                stub_request(:get, url)
                    .to_return(status: 200, body: response_body)

                expect(subject).to eq([])
            end
        end

        context "for one page of reviews" do
            it 'collects and returns the reviews' do
                response_body = File.read('spec/fixtures/lendingtree_reviews_page1.html')

                stub_request(:get, url)
                    .to_return(status: 200, body: response_body)

                response_body = File.read('spec/fixtures/lendingtree_no_reviews.html')

                stub_request(:get, "https://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_id}?sort=&pid=2")
                    .to_return(status: 200, body: response_body)

                expect(subject).to be_an(Array)
                expect(subject.count).to eq(10)
                expect(subject).to all(be_a(Review))
                expect(subject).to all(have_attributes(
                    lender_id: lender_id,
                    title: be_present,
                    content: be_present,
                    author: be_present,
                    star_rating: be_a(Numeric).and(be_between(1, 5)),
                    date: be_a(Date),
                    recommended: be_in([true, false]),
                    closed_with_lender: be_in([true, false])
                ))
            end
        end

        context "for multiple pages of reviews" do
            it 'collects and returns the reviews' do
                response_body = File.read('spec/fixtures/lendingtree_reviews_page1.html')

                stub_request(:get, url)
                    .to_return(status: 200, body: response_body)

                response_body = File.read('spec/fixtures/lendingtree_reviews_page2.html')

                stub_request(:get, "https://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_id}?sort=&pid=2")
                    .to_return(status: 200, body: response_body)

                response_body = File.read('spec/fixtures/lendingtree_no_reviews.html')

                stub_request(:get, "https://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_id}?sort=&pid=3")
                    .to_return(status: 200, body: response_body)

                expect(subject).to be_an(Array)
                expect(subject.count).to eq(14)
                expect(subject).to all(be_a(Review))
                expect(subject).to all(have_attributes(
                    lender_id: lender_id,
                    title: be_present,
                    content: be_present,
                    author: be_present,
                    star_rating: be_a(Numeric).and(be_between(1, 5)),
                    date: be_a(Date),
                    recommended: be_in([true, false]),
                    closed_with_lender: be_in([true, false])
                ))
            end
        end
    end
end
