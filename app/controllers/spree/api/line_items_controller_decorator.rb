Spree::Api::LineItemsController.class_eval do

  self.line_item_options += [:subscribe, :delivery_number, :subscription_frequency_id]

end
