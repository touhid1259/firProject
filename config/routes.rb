Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'homepage#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get '/controlling' => 'control#index'
  get '/energy' => 'energy#index'

  get 'energy/printer' => 'energy#printer_energy_data'
  get 'energy/printer/continuous' => 'energy#continuous_printer_energy_data'
  post 'energy/printer/consumption_on' => 'energy#get_datewise_printer_data'

  get '/demo_coding' => 'homepage#demo_coding'
  get '/demo_coding/demo_continuous_printer_energy_data' => 'homepage#demo_continuous_printer_energy_data'

  get '/energy/googleGraph_printer' => 'energy#googleGraph_printer_energy_data'
  get '/energy/googleGraph_printer/continuous' => 'energy#googleGraph_continuous_printer_energy_data'

  get '/energy/printer_prediction' => 'energy#printer_energy_prediction'
  get '/energy/printer_prediction/continuous' => 'energy#continuous_printer_energy_prediction'
  get '/energy/printer_prediction/static_ten_seconds' => 'energy#ten_sec_prediction_index'
  post '/energy/printer/ten_sec_consumption_prediction_on' => 'energy#get_ten_sec_prediction'

  get '/ewima/preference_selection' => 'ewima#select_your_preference'
  get '/ewima/summary' => 'ewima#summary_view'

  get '/ewima/rough_planning' => 'ewima#rough_planning'
  get '/ewima/detailed_planning' => 'ewima#detailed_planning'
  get '/ewima/planning_summary' => 'ewima#planning_summary'

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
