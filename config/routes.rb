Rails.application.routes.draw do
  get 'log_in' => 'sessions#new', :as => :log_in
  match 'log_out' => 'sessions#destroy', :as => :log_out, :via => [:get, :post]
  resources :sessions, :only => [:new, :create, :destroy]

  get '/' => 'suppliers#index', :as => :root

  resources :suppliers do
    resources :articles do # name_prefix => nil
      collection do
        delete :destroy_all
        get :upload
        post :parse
      end
    end
  end

  resources :users
end
