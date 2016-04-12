function AjaxHandler(classname, targets) {
  this.classname = classname;
  this.targets = targets;
}

AjaxHandler.prototype.init = function() {
  this.bindEvents();
};

AjaxHandler.prototype.bindEvents = function() {
  var _this = this;
  $.each(_this.targets, function(index, target) {
    var $target = $(target);
    $target.on('click', function() {
      var data = $target.data();
      if(confirm(data.confirm)) {
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
        _this.handle_destroy_success($target, response);
      } else {
        _this.handle_patch_success($target, response)
      }
    },
    error: function(response) {
      _this.handle_error_response($target, response);
    }
  });
};

AjaxHandler.prototype.handle_patch_success = function($target, response) {
  this.hide_flash_divs();
  $target.data("url", response.url);
  $target.toggleClass("btn-success");
  $target.toggleClass("btn-warning");
  $("#success_flash_message").html(response.flash).removeClass("hidden");
  var $symbol = $target.find(".icon");
  $symbol.toggleClass("icon-pause").toggleClass("icon-play");
  if ($target.find(".translation_missing").length) {
    $target.find(".translation_missing").html(response.button_text);
  } else {
    $target.html(response.button_text);
  }
};

AjaxHandler.prototype.handle_destroy_success = function($target, response) {
  this.hide_flash_divs();
  $("#success_flash_message").html(response.flash).removeClass("hidden");
  $('[data-id="' + response.subscription_id + '"] .subscription-action-links').html("Deleted");
};

AjaxHandler.prototype.handle_error_response = function($target, response) {
  this.hide_flash_divs();
  $("#error_flash_message").html(response.flash).removeClass("hidden");
};

AjaxHandler.prototype.hide_flash_divs = function() {
  $("#html_error_flash_message").remove();
  $("#error_flash_message").addClass("hidden");
  $("#html_success_flash_message").remove();
  $("#success_flash_message").addClass("hidden");
};

$(function (){
  var ajaxHandler = new AjaxHandler('pause', $('.ajax_handler'));
  ajaxHandler.init();
});
