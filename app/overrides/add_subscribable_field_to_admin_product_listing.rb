Deface::Override.new(
  virtual_path: "spree/admin/products/index",
  name: "add_subscribable_header_to_products_listing",
  insert_before: "[data-hook='admin_products_index_headers'] .text-center",
  partial: "spree/admin/products/subscribable_listing_header"
)

Deface::Override.new(
  virtual_path: "spree/admin/products/index",
  name: "add_subscribable_content_to_products_listing",
  insert_before: "[data-hook='admin_products_index_rows'] .text-center",
  partial: "spree/admin/products/subscribable_listing_content"
)
