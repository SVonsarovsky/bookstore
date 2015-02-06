RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit do
      except ['Order']
    end
    delete
    show_in_app do
      except ['Order']
    end
    state do
      visible do
        bindings[:abstract_model].model.to_s == 'Order'
      end
    end

    config.included_models = %w(Country ShippingMethod User Author Category Book Review Order)

    ## With an audit adapter, you can add:
    # history_index
    # history_show

    config.model User do
      label 'Customer'
      list do
        field :id
        field :email
        field :photo
        field :sign_in_count
        field :last_sign_in_at
      end
      edit do
        field :email
        field :password
        field :password_confirmation
        field :photo
      end
      show do
        field :id
        field :email
        field :photo
        field :sign_in_count
        field :current_sign_in_at
        field :last_sign_in_at
        field :current_sign_in_ip
        field :last_sign_in_ip
        field :created_at
        field :updated_at
      end
    end
    config.model Book do
      list do
        field :id
        field :title
        field :price
        field :image
        field :authors
        field :categories
      end
      edit do
        field :title
        field :price
        field :short_description
        field :image
        field :authors
        field :categories
        field :full_description, :ck_editor
      end
      show do
        field :id
        field :title
        field :price
        field :short_description
        field :full_description
        field :image
        field :authors do
          searchable :first_name, :last_name
        end
        field :categories
      end
    end
    config.model Category do
      list do
        field :id
        field :name
      end
      show do
        field :id
        field :name
      end
      edit do
        #field :id
        field :name
      end
    end
    config.model Author do
      list do
        field :id
        field :first_name
        field :last_name
        field :description
      end
      show do
        field :id
        field :first_name
        field :last_name
        field :description
      end
      edit do
        field :first_name
        field :last_name
        field :description
      end
    end
    config.model Review do
      list do
        field :id
        field :book
        field :user
        field :rating
        field :review
      end
      show do
        field :id
        field :book
        field :user
        field :rating
        field :text
      end
      edit do
        field :book
        field :user
        field :rating
        field :text
      end
    end
    config.model Order do
      list do
        field :id
        field :display_number do
          label 'Number'
        end
        field :totals do
          label 'Total price (items)'
        end
        field :state, :state
        field :user
        field :completed_at
      end
      edit do
        field :state, :state
      end
      show do
        field :id
        field :display_number do
          label 'Number'
        end
        field :totals do
          label 'Total price (items)'
        end
        field :state, :state
        field :user
        field :completed_at
        field :order_items
      end
    end

  end
end
