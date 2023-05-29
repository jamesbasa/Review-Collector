require 'rails_helper'

RSpec.describe "LendingTree Form" do
    describe "GET #lendingtree_form" do
        let(:lender_type) { "lender_type" }
        let(:lender_name) { "lender_name" }
        let(:lender_id) { "lender_id" }
        let(:form_button_name) { "Collect Reviews" }

        #  Future consideration: use factories such as Factory Bot
        let(:reviews) do
            [
                Review.new("Review1", "Brand1", "Title1", "Bad service", "Mike", "Pleasanton, CA", "1", Date.new(2023, 01, 01), false),
                Review.new("Review2", "Brand1", "Title2", "Average service", "Molly", "Oakland, CA", "3", Date.new(2023, 02, 01), true),
                Review.new("Review3", "Brand1", "Title3", "Good service", "Jim", "Dublin, CA", "4", Date.new(2023, 03, 01), true),
                Review.new("Review4", "Brand1", "Title4", "Great service", "Pat", "Fremont, CA", "5", Date.new(2023, 04, 01), true),
            ]
        end

        before do
            visit reviews_lendingtree_path
        end

        it "displays the form content" do
            within("form") do
                expect(page).to have_css('input[name="lender_type"][required][value="business"]')
                expect(page).to have_css('input[name="lender_name"][required]')
                expect(page).to have_css('input[name="lender_id"][required]')
                expect(page).to have_button(form_button_name)
            end
        end

        it "has the correct form action" do
            expect(page).to have_selector("form[action='#{reviews_lendingtree_path}'][method='get']")
        end

        context "when form is submitted" do
            context "when lender_type is invalid" do
                before do
                    fill_in "lender_type", with: "Error"
                    fill_in "lender_name", with: "not-ondeck"
                    fill_in "lender_id", with: "123"
                    click_button form_button_name
                end

                it "displays flash error for invalid lender_type" do
                    expect(page).to have_content(ReviewsController::INVALID_LENDER_TYPE_MESSAGE)
                end

                it "displays the initial lendingtree form" do
                    within("form") do
                        expect(page).to have_css('input[name="lender_type"][required][value="business"]')
                        expect(page).to have_css('input[name="lender_name"][required]')
                        expect(page).to have_css('input[name="lender_id"][required]')
                        expect(page).to have_button(form_button_name)
                    end
                end
            end

            context "when all fields are valid" do
                before do
                    within("form") do
                        fill_in "lender_type", with: "business"
                        fill_in "lender_name", with: "not-ondeck"
                        fill_in "lender_id", with: "123"
                    end
                end

                it "displays flash error for parsing error" do
                    allow(LendingtreeService).to receive(:collect_reviews).and_raise(LendingtreeService::ParsingError)
                    click_button form_button_name

                    expect(page).to have_content("Unable to retrieve data from the webpage")
                end

                it "displays flash error for review collection error" do
                    allow(LendingtreeService).to receive(:collect_reviews).and_raise(LendingtreeService::ReviewCollectionError)
                    click_button form_button_name

                    expect(page).to have_content("Unable to retrieve reviews")
                end

                it "displays the table of reviews" do
                    allow(LendingtreeService).to receive(:collect_reviews).and_return(reviews)
                    click_button form_button_name

                    expect(page).to have_content("Reviews: #{reviews.count} Total")
                    expect(page).to have_selector("table.reviews-table tbody tr", count: reviews.count)
                end

                it "displays the correct review details" do
                    allow(LendingtreeService).to receive(:collect_reviews).and_return(reviews)
                    click_button form_button_name

                    reviews.each do |review|
                        expect(page).to have_selector("table.reviews-table tbody tr", text: review.review_id)
                        expect(page).to have_selector("table.reviews-table tbody tr", text: review.title)
                        expect(page).to have_selector("table.reviews-table tbody tr", text: review.content)
                        expect(page).to have_selector("table.reviews-table tbody tr", text: review.author)
                        expect(page).to have_selector("table.reviews-table tbody tr", text: review.user_location)
                        expect(page).to have_selector("table.reviews-table tbody tr", text: review.star_rating)
                        expect(page).to have_selector("table.reviews-table tbody tr", text: review.date)
                        expect(page).to have_selector("table.reviews-table tbody tr", text: review.recommended)
                    end
                end

                it "displays the initial lendingtree form" do
                    allow(LendingtreeService).to receive(:collect_reviews).and_return(reviews)
                    click_button form_button_name

                    within("form") do
                        expect(page).to have_css('input[name="lender_type"][required][value="business"]')
                        expect(page).to have_css('input[name="lender_name"][required]')
                        expect(page).to have_css('input[name="lender_id"][required]')
                        expect(page).to have_button(form_button_name)
                    end
                end

                context "when no reviews are retrieved" do
                    let(:reviews) { [] }

                    it "displays no reviews" do
                        allow(LendingtreeService).to receive(:collect_reviews).and_return(reviews)
                        click_button form_button_name

                        expect(page).to have_content("No reviews found.")
                        expect(page).to have_no_selector("table.reviews-table")
                    end
                end
            end
        end
    end
end
  