class Review
    # not persisted in a DB

    attr_accessor :lender_id, :title, :content, :author, :star_rating, :date, :recommended, :closed_with_lender
    
    def initialize(lender_id, title, content, author, star_rating, date, recommended, closed_with_lender)
        @lender_id = lender_id
        @title = title
        @content = content
        @author = author
        @star_rating = star_rating
        @date = date
        @recommended = recommended
        @closed_with_lender = closed_with_lender
    end
end
