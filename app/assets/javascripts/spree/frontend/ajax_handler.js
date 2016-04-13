function AjaxHandler(targets) {
  this.targets = targets;
}

AjaxHandler.prototype.init = function() {
  this.bindEvents();
};

AjaxHandler.prototype.bindEvents = function() {
  var _this = this;
  $.each(_this.targets, function(index, target) {
    var $target = $(target);
    $target.unbind('click').on('click', function() {
      var data = $target.data();
      if(confirm(data.confirmation)) {
        _this.sendRequest($target, data);
      }
    });
  });
};

AjaxHandler.prototype.sendRequest = function($target, data) {
  var _this = this;
  $.ajax({
    url: data.url,
    dataType: "JSON",
    method: data.method,
    success: function(response) {
      if (data.method == "DELETE") {
        _this.handleDestroySucess($target, response);
      } else {
        _this.handlePatchSuccess($target, response)
      }
    },
    error: function(response) {
      _this.handleErrorResponse($target, response);
    }
  });
};

AjaxHandler.prototype.handlePatchSuccess = function($target, response) {
  this.hideFlashDivs();
  $target.data("url", response.url);
  $target.toggleClass("btn-success");
  $target.toggleClass("btn-warning");
  $("#success_flash_message").html(response.flash).removeClass("hidden");
  var $symbol = $target.find(".icon");
  $symbol.toggleClass("icon-pause").toggleClass("icon-play");
  if (!$target.find(".translation_missing").length && !$symbol.length) {
    $target.html(response.button_text);
  }
  $target.find(".translation_missing").html(response.button_text);
  $target.data("confirmation", response.confirmation);
};

AjaxHandler.prototype.handleDestroySucess = function($target, response) {
  this.hideFlashDivs();
  $("#success_flash_message").html(response.flash).removeClass("hidden");
  $('[data-id="' + response.subscription_id + '"] .subscription-action-links').html("Deactivated");
};

AjaxHandler.prototype.handleErrorResponse = function($target, response) {
  this.hideFlashDivs();
  $("#error_flash_message").html(response.flash).removeClass("hidden");
};

AjaxHandler.prototype.hideFlashDivs = function() {
  $("#html_error_flash_message").remove();
  $("#error_flash_message").addClass("hidden");
  $("#html_success_flash_message").remove();
  $("#success_flash_message").addClass("hidden");
};

$(function (){
  var ajaxHandler = new AjaxHandler($('.ajax_handler'));
  ajaxHandler.init();
});
