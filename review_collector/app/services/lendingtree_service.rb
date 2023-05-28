class LendingtreeService
    MAX_PAGE_SIZE = 400

    class BrandIdError < StandardError
        def initialize(message = "Unable to retrieve brand ID")
            super
        end
    end

    class ReviewCollectionError < StandardError
        def initialize(message = "Unable to retrieve reviews")
            super
        end
    end

    def self.collect_reviews(lender_type, lender_name, lender_id)
        validate_parameters(lender_type, lender_name, lender_id)

        reviews = []
        page = 0

        brand_id = get_brand_id(lender_type, lender_name, lender_id)

        while true
            url = "https://www.lendingtree.com/wp-json/review/proxy?"\
                  "RequestType=&productType=&brandId=#{brand_id}&requestmode=reviews&"\
                  "page=#{page}&sortby=reviewsubmitted&sortorder=desc&pagesize=#{MAX_PAGE_SIZE}&"\
                  "AuthorLocation=All&OverallRating=0&_t=1685253503993"
            headers = {
                # 'Accept-Language': 'en-US,en;q=0.9',
                # 'Referer': 'https://www.lendingtree.com/reviews/personal/zable/135373435?sort=&pid=2',
                # 'Origin': 'https://www.lendingtree.com',
                # 'X-Requested-With': 'XMLHttpRequest',
                'X-Wp-Nonce': '5c820001b6'
            }
            response = HTTParty.get(url, headers: headers)
            raise ReviewCollectionError unless response.success?

            reviews_hash = JSON.parse(response)['result']['reviews']
            break if reviews_hash.blank?

            reviews_hash.each do |review|
                id = review['id']
                title = review['title']
                content = review['text']
                author = review['authorName']
                user_location = review['userLocation']
                star_rating = review['primaryRating']['value']&.to_i
                date = Date.parse(review['submissionDateTime'])
                recommended = review['isRecommended']

                reviews << Review.new(id, brand_id, title, content, author, user_location, star_rating, date, recommended)
            end

            page += 1
        end

        reviews
    rescue ArgumentError
        raise
    rescue BrandIdError
        raise
    rescue HTTParty::Error, StandardError => e
        raise ReviewCollectionError
    end

    private

    def self.validate_parameters(lender_type, lender_name, lender_id)
        raise ArgumentError, "Invalid parameters" unless lender_type.present? && lender_name.present? && lender_id.present?
    end

    def self.get_brand_id(lender_type, lender_name, lender_id)
        url = "https://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_id}"
        response = HTTParty.get(url)
        raise BrandIdError unless response.success?

        doc = Nokogiri::HTML(response.body)

        brand_id = doc.at_css('button.write-review[data-lenderreviewid]')&.attr('data-lenderreviewid')&.to_s
        raise BrandIdError unless brand_id

        brand_id
    rescue HTTParty::Error, StandardError => e
        raise BrandIdError
    end
end
