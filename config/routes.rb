Spree::Core::Engine.routes.draw do

  namespace :admin do
    resources :subscriptions do
    end
  end

end
