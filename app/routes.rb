Discourse::Application.routes.append do
  resources :collusions, only: [:show, :create] do
    post :toggle, on: :member
  end
end
