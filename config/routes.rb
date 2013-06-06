Veggie::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  require 'sidekiq/web'
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :members, :controllers => {
   :omniauth_callbacks => :authentications,
   :sessions => :sessions
  }

  # olive
  get "o", :to => "olive#index", :as => :olive
  namespace :olive do
    get 'courses'
    get 'quotes'
    get 'persons'
    get 'songs'
    post 'create_quote'
    post 'destroy_tag'
  end

  namespace :courses do
    post 'checkin'
    post 'update'
    post 'ready'
    post 'open'
    post 'destroy'
  end

  namespace :words do
    get "index"
    post 'fetch'
    post 'upload_img_u'
    post 'upload_audio_u'
  end

  namespace :songs do
    post 'create'
    post 'upload'
  end
  
  # members
  get "account",:to => "members#index"
  get "achieve",:to => "members#index"
  get "teach",:to => "members#index"
  namespace :members do
    post "update"
    post "upload_avatar"
    post "send_invite"
    get "dashboard"
    get "account"
    get "profile"
    get "provider"
    get "teach"
    get "friend"
    get "invite_list"
    post "like"
    post "invite_friend"
  end

  #mobile
  namespace :mobile do
    get "fetch"
    post "make_word"
  end
  # 如果是移动设备，则以移动版本渲染
  mobile_devise = lambda { |request| 
    agent = request.user_agent.downcase
    agent.include?("iphone") or agent.include?("android")
  }
  constraints mobile_devise do
     root :to => 'mobile#index' 
  end
  
  authenticated :member do
    root :to => "members#index"
  end
  root :to => 'home#index'
  
  get "lab" => "mobile#lab"

  get ":role/:uid",:to => "members#show"

  # See how all your routes lay out with "rake routes"
  unless Rails.application.config.consider_all_requests_local
    get '*not_found', to: 'errors#error_404'
  end
end
