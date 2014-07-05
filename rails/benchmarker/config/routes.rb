Benchmarker::Application.routes.draw do
  root to: "pages#index"
  get "/:title", to: "pages#index"
  get "/api/:title", to: "pages#api"
end
