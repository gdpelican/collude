Discourse::Application.routes.append do
  resources :collusions, only: [:show, :create]
end
