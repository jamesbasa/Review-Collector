class Review
    # not persisted in a DB

    attr_accessor :review_id, :brand_id, :title, :content, :author, :user_location, :star_rating, :date, :recommended
    
    def initialize(review_id, brand_id, title, content, author, user_location, star_rating, date, recommended)
        @review_id = review_id
        @brand_id = brand_id
        @title = title
        @content = content
        @author = author
        @user_location = user_location
        @star_rating = star_rating
        @date = date
        @recommended = recommended
    end
end
