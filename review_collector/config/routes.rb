Rails.application.routes.draw do
    get 'reviews/lendingtree/:lender_type/:lender_name/:lender_id', to: 'reviews#lendingtree'
    get 'reviews/lendingtree', to: 'reviews#lendingtree_form'

    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Defines the root path route ("/")
    # root "articles#index"
end
