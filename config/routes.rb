Spree::Core::Engine.routes.draw do

  namespace :admin do
    resources :subscriptions do
      member do
        patch 'pause'
        patch 'unpause'
        get 'cancellation'
        patch 'cancel'
      end
    end
  end

  resources :subscriptions do
    member do
      patch 'pause'
      patch 'unpause'
      patch 'cancel'
    end
  end

end
