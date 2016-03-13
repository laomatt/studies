Rails.application.routes.draw do
  devise_for :users

  resources :slideshows do
    member do
      get 'draw'
      get 'get_image'
      get 'get_image_slide_show'
      get 'get_image_slide_show_tags'
      get 'draw_set'
      get 'get_images_from_show'
      get 'toggle_public'
      patch 'mark_all_slides_nsfw'
    end

    collection do
      post 'update_slide_show'
      post 'update_slide_show_slide_tags'
      put 'update_image_position'
      get 'find_slide'
      get 'get_images_from_show_random'
      get 'get_images_from_show_tag'
      get 'get_images_from_show_your'
      get 'get_images_from_show_likes'
      get 'draw_set_random'
      get 'draw_set_your'
      get 'draw_set_likes'
    end
  end

  resources :user do

  end

  resources :slides do
    member do
      post 'like_a_slide'
      get 'get_partial'
      delete 'destroy_this_slide'
      delete 'unlike_slide'
      patch 'toggle_nsfw'
    end
  end

  resources :tags do
    collection do
      get 'browse_tags'
    end

    member do
      get 'show_tag'
      get 'get_tag_partial'
    end
  end

  resources :home do
    member do
      get 'create_slide_show'
      patch 'add_image'
      post 'add_image_url'
      post 'add_image_community'
      get 'upload_images'
      get 'user_shows'
      get 'user_slides'
    end

    collection do
      get 'get_faq'
      get 'exp'
      get 'ind'
      get 'user_slideshows'
      get 'user_slides'
      post 'save_slide_show'
    end
  end



  devise_scope :user do
    get 'user_log_out_route/sign_out', :to => 'devise/sessions#destroy'
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
