// nav drop down menu
$('body').on('click', '.content-container', function(event) {
  var ele = $(this).parent().find('ul.dropdown-menu');
  event.preventDefault();
  ele.slideUp(300);
});

$("body").on('click', '.dropdown-toggle', function(event) {
  event.preventDefault();
  var ele = $(this).parent().find('ul.dropdown-menu');
  if(ele.css('display') == 'none'){
    ele.slideDown(300);
  } else {
    ele.slideUp(300);
    $('body').on('click', function(event) {
      event.preventDefault();
    });

  }
});

// back drop

$('body').on('click', '.backdrop', function(event) {
  event.preventDefault();
  $(this).fadeOut(300, function() {

  });
  $(".form-modal").fadeOut(300, function() {});
});

// slide show edits and upload new slides

$('body').on('mouseup', '.slideshow_lists_edit li', function(event) {
  event.preventDefault();
  var ss_id = $(this).attr('ssid');
  setTimeout(function(){
    $.each($(".slideshow_lists_edit li"), function(index, val) {
      console.log(val, index)
      var id = $(this).attr("pic-id")
      $.ajax({
        url: '/slideshows/update_image_position',
        type: 'PUT',
        data: {position: index, slide_id: id, id: ss_id},
      })
    });
  }, 500)
  successFunction();
});
$("body").on('submit', 'form#save_slide', function(event) {
  event.preventDefault();
  var path = $(this).attr('action');
  $.ajax({
    url: path,
    type: 'POST',
    data: $(this).serialize(),
  })
  .done(function(data) {
    console.log("success");
    successFunction();
  })
});

var successFunction = function(){
  $(".success").fadeIn(1000, function() {
    $(this).fadeOut(1500, function() {
    });
  });
}

$('body').on('mouseenter', '.slideshow_lists_edit li', function(event) {
  event.preventDefault();
  $(this).find('.pic-info').fadeIn(300, function() {});
});

$('body').on('mouseleave', '.slideshow_lists_edit li', function(event) {
  event.preventDefault();
  $(this).find('.pic-info').fadeOut(300, function() {});
});


$('body').on('click', '#upload-pic', function(event) {
  event.preventDefault();
  $('form#upload').trigger('submit');
});

$("body").on('submit', 'form#upload', function(event) {
  event.preventDefault();
  var id = $("#info").attr('ssid');
  $('body').css('opacity', .5);

  $.ajax({
    url: "/home/"+id+"/add_image",
    type: 'PATCH',
    data: new FormData( this ),
    processData: false,
    contentType: false,
  })
  .done(function(data) {
    var source = $("#entry-template").html();
    var template = Handlebars.compile(source);
    var context = data;
    var html = template(context);
    $("ul.slideshow_lists_edit").append(html);

    $("form#upload").trigger('reset');
    $('body').css('opacity', 1);
  })
});

$("body").on('click', '#upload-pic-url', function(event) {
  event.preventDefault();
  var id = $("#info").attr('ssid');
  $('body').css('opacity', .5);
  $.ajax({
    url: "/home/"+id+"/add_image_url",
    type: 'POST',
    data: $("form#upload-url").serialize(),
  })
  .done(function(data) {
    var source = $("#entry-template").html();
    var template = Handlebars.compile(source);
    var context = data;
    var html = template(context);
    debugger
    $("ul.slideshow_lists_edit").append(html);

    $("form#upload-url").trigger('reset');
    $('body').css('opacity', 1);
  })
});

