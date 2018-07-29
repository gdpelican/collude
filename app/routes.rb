Discourse::Application.routes.append do
  resources :posts do
    get :collude, on: :member
    post :perform_collusion, on: :member
  end
end
