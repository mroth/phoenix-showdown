Benchmarker::Application.routes.draw do
  root to: "pages#index"
  get "/:title", to: "pages#index"
end
