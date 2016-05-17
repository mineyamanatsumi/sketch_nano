'use strict'

$(function () {
  $('button.like').click(function (e) {
    var $clicked = $(this);
    var dataId   = $clicked.data('id');
    var likes    = $clicked.text();

    $.post("/api/like", { 'dataid': dataId, 'likes':likes }, function(result) {
      $clicked.text(result.like);
    });

  });
});
