class LendingtreeService
    def self.collect_reviews(lender_type, lender_name, lender_id)
        validate_parameters(lender_type, lender_name, lender_id)

        reviews = []
        page = 1

        while true
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

                reviews << Review.new(lender_id, title, content, author, star_rating, date, recommended, closed_with_lender)
            end

            page += 1
        end

        reviews
    end

    private

    def self.validate_parameters(lender_type, lender_name, lender_id)
        raise ArgumentError, "Invalid parameters" unless lender_type.present? && lender_name.present? && lender_id.present?
    end
end
