Chordination::Application.routes.draw do
  devise_for :users

  devise_scope :user do
    get "login" => "devise/sessions#new"
    delete "logout" => "devise/sessions#destroy"
    get "profile" => "devise/registrations#edit"
    get "register" => "devise/registrations#new"
    post "register" => "devise/registrations#create"
  end

  get "dashboard" => "pages#dashboard"
  
  get "entries/:key/new" => "entries#new"
  get "entries/:key" => "entries#show"
  get "entries/:key/edit" => "entries#edit"
  put "entries/:key" => "entries#update"
  post "entries/:key/accept" => "entries#accept"
  delete "entries/:key/remove" => "entries#remove"
      
  resources :scoresheets do
    resources :bets
    resources :participants do
      member do
        get "reinvite"
      end
    end
  end
  
  
  
  root :to => 'pages#home'
end
