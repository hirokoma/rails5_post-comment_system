Rails.application.routes.draw do
  scope '/api' do
    mount_devise_token_auth_for 'User', at: 'auth'
    resources :posts
    resources :comments

    post '/issue_upload_token', to: 'uploads#issue_upload_token'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  end
end
