Spree::Core::Engine.routes.draw do

  namespace :admin do
    resources :subscriptions do
      member do
        get 'cancellation'
        patch 'cancel'
      end
    end
  end

end
