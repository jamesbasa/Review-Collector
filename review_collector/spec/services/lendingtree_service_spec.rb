require 'rails_helper'
require 'webmock/rspec'

RSpec.describe LendingtreeService do
    describe '#collect_reviews' do
        subject { LendingtreeService.collect_reviews(lender_type, lender_name, lender_id) }

        let(:lender_type) { 'business' }
        let(:lender_name) { 'not-ondeck' }
        let(:lender_id) { '123' }
        let(:brand_id) { '45275' }
        let(:url) { "https://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_id}" }

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

        context 'when http request to the homepage is unsuccessful' do
            it 'raises an error given a 400' do
                stub_request(:get, url)
                    .to_return(status: 400)

                expect {
                    subject
                }.to raise_error(LendingtreeService::BrandIdError)
            end

            it 'raises an error given an HTTParty::Error' do
                stub_request(:get, url)
                    .to_raise(HTTParty::Error)

                expect {
                    subject
                }.to raise_error(LendingtreeService::BrandIdError)
            end
        end

        context "when http request to the homepage is successful" do
            let(:proxy_headers) do
                {
                    'X-Wp-Nonce': '5c820001b6'
                }
            end

            before do
                response_body = File.read('spec/fixtures/lendingtree_reviews_homepage.html')

                stub_request(:get, url)
                    .to_return(status: 200, body: response_body)
            end

            context 'when unable to retrieve the brand id on the homepage' do
                it 'raises an error' do
                    allow_any_instance_of( Nokogiri::HTML::Document).to receive(:at_css).and_return(nil)

                    expect {
                        subject
                    }.to raise_error(LendingtreeService::BrandIdError)
                end
            end

            context 'when there are no reviews' do
                it 'returns an empty array' do
                    response_body = File.read('spec/fixtures/lendingtree_no_reviews.json')

                    proxy_url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                                "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                                "page=0&sortby=reviewsubmitted&sortorder=desc&pagesize=#{LendingtreeService::MAX_PAGE_SIZE}&"\
                                "AuthorLocation=All&OverallRating=0&_t=1685253503993"
                    stub_request(:get, proxy_url)
                        .with(headers: proxy_headers)
                        .to_return(status: 200, body: response_body)

                    response_body = File.read('spec/fixtures/lendingtree_no_reviews.json')

                    expect(subject).to eq([])
                end
            end

            context "for one page of reviews" do
                it 'collects and returns the reviews' do
                    response_body = File.read('spec/fixtures/lendingtree_reviews_page1.json')

                    proxy_url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                                "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                                "page=0&sortby=reviewsubmitted&sortorder=desc&pagesize=#{LendingtreeService::MAX_PAGE_SIZE}&"\
                                "AuthorLocation=All&OverallRating=0&_t=1685253503993"
                    stub_request(:get, proxy_url)
                        .with(headers: proxy_headers)
                        .to_return(status: 200, body: response_body)

                    response_body = File.read('spec/fixtures/lendingtree_no_reviews.json')

                    proxy_url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                                "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                                "page=1&sortby=reviewsubmitted&sortorder=desc&pagesize=#{LendingtreeService::MAX_PAGE_SIZE}&"\
                                "AuthorLocation=All&OverallRating=0&_t=1685253503993"

                    stub_request(:get, proxy_url)
                        .with(headers: proxy_headers)
                        .to_return(status: 200, body: response_body)

                    expect(subject).to be_an(Array)
                    expect(subject.count).to eq(10)
                    expect(subject).to all(be_a(Review))
                    expect(subject).to all(have_attributes(
                        review_id: be_present,
                        brand_id: brand_id,
                        title: be_present,
                        content: be_present,
                        author: be_present,
                        user_location: be_present,
                        star_rating: be_a(Numeric).and(be_between(1, 5)),
                        date: be_a(Date),
                        recommended: be_in([true, false]),
                    ))
                end
            end

            context "for multiple pages of reviews" do
                it 'collects and returns the reviews' do
                    response_body = File.read('spec/fixtures/lendingtree_reviews_page1.json')

                    proxy_url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                                "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                                "page=0&sortby=reviewsubmitted&sortorder=desc&pagesize=#{LendingtreeService::MAX_PAGE_SIZE}&"\
                                "AuthorLocation=All&OverallRating=0&_t=1685253503993"
                    stub_request(:get, proxy_url)
                        .with(headers: proxy_headers)
                        .to_return(status: 200, body: response_body)

                    response_body = File.read('spec/fixtures/lendingtree_reviews_page2.json')

                    proxy_url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                                "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                                "page=1&sortby=reviewsubmitted&sortorder=desc&pagesize=#{LendingtreeService::MAX_PAGE_SIZE}&"\
                                "AuthorLocation=All&OverallRating=0&_t=1685253503993"

                    stub_request(:get, proxy_url)
                        .with(headers: proxy_headers)
                        .to_return(status: 200, body: response_body)

                    response_body = File.read('spec/fixtures/lendingtree_no_reviews.json')

                    proxy_url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                                "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                                "page=2&sortby=reviewsubmitted&sortorder=desc&pagesize=#{LendingtreeService::MAX_PAGE_SIZE}&"\
                                "AuthorLocation=All&OverallRating=0&_t=1685253503993"

                    stub_request(:get, proxy_url)
                        .with(headers: proxy_headers)
                        .to_return(status: 200, body: response_body)

                    expect(subject).to be_an(Array)
                    expect(subject.count).to eq(15)
                    expect(subject).to all(be_a(Review))
                    expect(subject).to all(have_attributes(
                        review_id: be_present,
                        brand_id: brand_id,
                        title: be_present,
                        content: be_present,
                        author: be_present,
                        user_location: be_present,
                        star_rating: be_a(Numeric).and(be_between(1, 5)),
                        date: be_a(Date),
                        recommended: be_in([true, false]),
                    ))
                end
            end

            context 'when http request for reviews is unsuccessful' do
                it 'raises an error given a 400' do
                    response_body = File.read('spec/fixtures/lendingtree_reviews_page1.json')

                    proxy_url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                                "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                                "page=0&sortby=reviewsubmitted&sortorder=desc&pagesize=#{LendingtreeService::MAX_PAGE_SIZE}&"\
                                "AuthorLocation=All&OverallRating=0&_t=1685253503993"
                    stub_request(:get, proxy_url)
                        .with(headers: proxy_headers)
                        .to_return(status: 400)
    
                    expect {
                        subject
                    }.to raise_error(LendingtreeService::ReviewCollectionError)
                end
    
                it 'raises an error given an HTTParty::Error' do
                    response_body = File.read('spec/fixtures/lendingtree_reviews_page1.json')

                    proxy_url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                                "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                                "page=0&sortby=reviewsubmitted&sortorder=desc&pagesize=#{LendingtreeService::MAX_PAGE_SIZE}&"\
                                "AuthorLocation=All&OverallRating=0&_t=1685253503993"
                    stub_request(:get, proxy_url)
                        .with(headers: proxy_headers)                        
                        .to_raise(HTTParty::Error)
    
                    expect {
                        subject
                    }.to raise_error(LendingtreeService::ReviewCollectionError)
                end
            end
        end
    end
end
