Deface::Override.new(
  virtual_path: 'spree/admin/products/index',
  name: 'add_subscribable_filter_to_products',
  insert_bottom: "[data-hook='admin_products_index_search'] .col-md-12",
  text: "<div class='field checkbox'>
          <label>
            <%= f.check_box :subscribable_eq, { :checked => params[:q][:subscribable_eq] == '1' }, '1', '0' %>
            <%= Spree.t(:show_subscribable ) %>
          </label>
         </div>"
)
