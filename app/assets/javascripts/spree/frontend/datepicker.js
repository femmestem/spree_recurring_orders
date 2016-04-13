//= require jquery-ui/datepicker

$(function() {
  $('.datepicker').datepicker({
    dateFormat: "dd-mm-yy",
    minDate: new Date()
  });
});
