Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "add_checkboxes_to_cart_form",
  insert_before: ".add-to-cart",
  partial: "spree/products/cart_checkboxes"
)
