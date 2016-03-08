Deface::Override.new(
  virtual_path: 'spree/shared/_order_details',
  name: "add_subscription_header_to_order_details",
  insert_bottom: "#line_items thead tr",
  partial: "spree/orders/cart_subscription_header"
)

Deface::Override.new(
  virtual_path: 'spree/shared/_order_details',
  name: "add_subscription_header_to_order_details",
  insert_bottom: "#line_items tbody tr",
  partial: "spree/orders/subscription_field"
)

Deface::Override.new(
  virtual_path: 'spree/shared/_order_details',
  name: "add_subscription_header_to_order_details",
  insert_bottom: "#line_items tfoot tr",
  partial: "spree/orders/cart_subscription_footer"
)
