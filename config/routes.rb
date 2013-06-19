Chordination::Application.routes.draw do
  devise_for :users

  devise_scope :user do
    get "login" => "devise/sessions#new"
    delete "logout" => "devise/sessions#destroy"
    get "profile" => "devise/registrations#edit"
    get "register" => "devise/registrations#new"
    post "register" => "devise/registrations#create"
  end
  get "about" => "pages#about"
  get "dashboard" => "pages#dashboard"
  
  get "entries/:key/new" => "entries#new"
  get "entries/:key" => "entries#show"
  get "entries/:key/edit" => "entries#edit"
  put "entries/:key" => "entries#update"
  post "entries/:key/accept" => "entries#accept"
  delete "entries/:key/decline" => "entries#decline"
  post "entries/:key/message" => "entries#message"
      
  resources :scoresheets do
    member do
      get 'results' => "bets#results"
      put 'results' => "bets#save_results"
      get 'clone' => "scoresheets#new"
    end
    resources :bets
    resources :results
    resources :participants do
      member do
        get "reinvite"
      end
    end
  end
  
  root :to => 'pages#home'
end
