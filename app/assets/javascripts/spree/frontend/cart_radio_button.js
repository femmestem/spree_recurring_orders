function CartRadioButton($radioButtons) {
  this.$radioButtons = $radioButtons;
}

CartRadioButton.prototype.init = function() {
  this.bindEvents();
};

CartRadioButton.prototype.bindEvents = function() {
  var _this = this;
  this.$radioButtons.on("change", function() {
    _this.toggleDiv($(this));
  });
};

CartRadioButton.prototype.toggleDiv = function($checkBox) {
  $($checkBox.val()).show();
  this.hideOtherDivs();
};

CartRadioButton.prototype.hideOtherDivs = function() {
  $.each(this.$radioButtons, function(index, value) {
    $checkBox = $(value);
    if (!$checkBox.prop("checked")) {
      $($checkBox.val()).hide();
    }
  });
};

$(function() {
  var cartRadioButton = new CartRadioButton($(".cart_radio_button"));
  cartRadioButton.init();
});
