# Review-Collector

### Requirements
1. Please write in ruby or python
2. Use this website: https://www.lendingtree.com/reviews/business
3. Write a web service that accepts requests of 'business' URLs (i.e. https://www.lendingtree.com/reviews/business/ondeck/51886298)
4. This service should collect all 'reviews' on the URL defined
5. The response should consist of: title of the review, the content of review, author, star rating, date of review, and any other info you think would be relevant
6. Write tests for your API
7. No need to make a view and datastore is optional
8. Error/bad request handling should be built out

### How to run via frontend
1. Change into the rails directory using `cd review_collector`
2. Start the server using `rails s`
3. Visit http://127.0.0.1:3000/reviews/lendingtree
4. Fill out the `lender name` and `lender id`
5. Click the button to collect reviews
6. The reviews will be displayed in a table once they are collected

### How to run via API/Postman/Curl

### How to run tests
