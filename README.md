# Review-Collector

## Summary
An API that collects reviews from [Lendingtree](https://www.lendingtree.com/reviews).

## Project Structure
review_collector/
├── app/
│   ├── controllers/
│   │   └── reviews_controller.rb
│   ├── models/
│   │   └── review.rb
│   ├── services/
│   │   └── lendingtree_service.rb
│   └── views/
│       └── reviews/
│           └── lendingtree_form.html.erb
├── config/
│   └── routes.rb
├── spec/
│   ├── controllers/
│   │   └── reviews_controller_spec.rb
│   ├── fixtures/
│   │   └── *several*
│   └── models/
│   │   └── review_spec.rb
│   └── services/
│       └── lendingtree_service_spec.rb
├── Gemfile
README.md

## Usage Instructions
### How to run via frontend
1. Change into the rails directory using `cd review_collector`
2. Start the server using `rails s`
3. Visit http://127.0.0.1:3000/reviews/lendingtree
4. Fill out the `lender name` and `lender id`
5. Click the button to collect reviews
6. The reviews will be displayed in a table once they are collected

### How to run via API (Postman)
1. Access my Postman workspace here: https://www.postman.com/spacecraft-observer-56275265/workspace/review-collection
2. Start the server locally using `rails s`
3. Test GET requests using any of the configured Postman 'collections' in the workspace. Each has several Postman tests setup.

### How to execute tests
1. Change into the rails directory using `cd review_collector`
2. Run all Rspecs using `rspec -fd spec`
