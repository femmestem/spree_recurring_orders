// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/backend/all.js'
$(function() {
  $("[data-hook='admin_product_form_subscribable']").find("#product_subscribable").on("change", function(){
    if ($(this).checked == true) {
      $("#subscribable_options").show();
    } else {
      $("#subscribable_options").hide();
    }
  });
});
