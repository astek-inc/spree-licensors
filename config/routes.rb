Spree::Core::Engine.routes.draw do

  get 'licensor', to: 'licensors#show', as: :licensor
  post 'licensor', to: 'licensors#show', as: :licensor_report

  namespace :admin do

    resources :users do
      resource :licensor #, except: :show, path_names: { edit: "" }
    end

    resources :reports, only: [:index] do #, :show] do
      collection do
        get :licensors
        post :licensors
        get :licensors_csv_export, defaults: { format: 'csv' }

        get 'licensor/:id', to: 'reports#licensor',  as: :licensor
        get 'licensor_csv_export/:id', to: 'reports#licensor_csv_export',  as: :licensor_csv_export, defaults: { format: 'csv' }
      end
    end
  end

end
