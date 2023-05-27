class Review
    # not persisted in a DB

    attr_accessor :title, :content, :author, :star_rating, :date, :recommended, :closed_with_lender
    
    def initialize(title, content, author, star_rating, date, recommended, closed_with_lender)
        @title = title
        @content = content
        @author = author
        @star_rating = star_rating
        @date = date
        @recommended = recommended
        @closed_with_lender = closed_with_lender
    end
end
