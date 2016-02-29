Thing::Application.routes.draw do
  namespace :admin do
    resources :users do
      get :send_password_reset_email
    end
    resources :tracks
    resources :instructor_email_list
    resources :track_lead_email_list
    resources :backups
    resources :reports do
      collection do
        get :instructor_signin
        get :kingdom_war_points
      end
    end
  end

  namespace :coordinator do
    resources :instructables
    resources :conflicts
    resources :locations do
      collection do
        get :timesheets
        get :freebusy
      end
    end
  end

  namespace :proofreader do
    resources :instructables
  end

  match 'sitemap(.:format)' => 'sitemap#index'

  match 'about/:action' => 'about'
  match '/about' => 'about#about'
  root :to => 'about#index'

  match 'howto/:action' => 'howto', as: :howto

  devise_for :users, path: 'sessions'

  resources :users do
    resource :instructor_profile
    resources :instructables
    resource :schedule, controller: 'users/schedules'
  end

  resources :calendars
  resources :changelogs
  resources :instructors

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
