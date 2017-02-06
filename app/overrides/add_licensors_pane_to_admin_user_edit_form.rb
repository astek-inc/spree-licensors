Deface::Override.new(
    # :original => 'a2e58f4c6e226d173c5dc642aea458728f54bff6',
    :virtual_path => 'spree/admin/users/edit',
    :name => 'add_licensors_pan_to_admin_user_edit_form',
    :insert_after => '#admin_user_edit_api_key',
    :partial => 'spree/admin/users/licensor'
)
