// nav drop down menu
$('body').on('click', '.content-container', function(event) {
  $('.dropdown-menu').slideUp(300);
});

$("body").on('click', '.dropdown-toggle', function(event) {
  var ele = $(this).parent().find('ul.dropdown-menu');
  if(ele.css('display') == 'none'){
    ele.slideDown(300);
  } else {
    ele.slideUp(300);
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
    successFunction();
    $('.backdrop').trigger('click');
    $('h1.head-edit-title').text(data.title);
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

$('body').on('mouseenter', '.my-slide', function(event) {
  event.preventDefault();
  $(this).find('.pic-info-myslides').fadeIn(300, function() {});
});

$('body').on('mouseleave', '.my-slide', function(event) {
  event.preventDefault();
  $(this).find('.pic-info-myslides').fadeOut(300, function() {});
});



$('body').on('click', '#upload-pic', function(event) {
  event.preventDefault();
  $('.backdrop').trigger('click')
  $(this).parent().find('form').trigger('submit');
});

$("body").on('submit', '.panelthird form#upload', function(event) {
  event.preventDefault();
  var id = $("#info").attr('ssid');
  var fileInput = document.getElementById("slideshow_picture");
  var files = fileInput.files;
  var length = files.length;
  var formData = new FormData( this );
  var ele = $('.screen-load');

  $.each(files, function(index, val) {
    formData.append('image_this['+index+']', val)
  });

    ele.fadeIn(400);
    $.ajax({
      url: "/home/"+id+"/add_image",
      type: 'PATCH',
      data: formData,
      processData: false,
      contentType: false,
    })
    .done(function(data_first) {
      var slides_to_check = data_first.slides
      function runRecurs(slides_to_check){
        setTimeout(function(){
          $.ajax({
            url: '/home/check_progress',
            data: {slides_to_check: slides_to_check},
          })
          .done(function(data) {
            console.log(data)
            if (data.result >= 100) {
              ele.fadeOut(1000);
              var finishedSlidesArray = data.slides;
              $.each(finishedSlidesArray, function(index, val) {
                var source = $("#entry-template-s3").html();
                var template = Handlebars.compile(source);
                var context = val;
                var html = template(context);
                $("ul.slideshow_lists_edit").append(html);
              });
              $('li.entry').fadeIn(1000, function() {
                $('li.entry').animate({'border-color': 'black'}, 1000)
              });
            } else {
              $('.prog-slider').animate({width: data.result+'%'}, 400)
              runRecurs(data.slides_to_check);
            };
          });

        }, 1000);
      }
      runRecurs(slides_to_check);
  });
});

$("body").on('click', '#upload-pic-url', function(event) {
  event.preventDefault();
  var id = $("#info").attr('ssid');
  $('backdrop').trigger('click');
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
    $("ul.slideshow_lists_edit").append(html);

    $("form#upload-url").trigger('reset');
    $('.backdrop').trigger('click');
  })
});

// slide inspect, edit code

$('body').on('click', '.inspect-slide', function(event) {
  event.preventDefault();
  var id = $(this).attr('data-id');
  $.ajax({
    url: '/slides/'+ id +'/get_partial',
    data: {type: 'inspect'},
  })
  .done(function(data) {
    $("#slide_inspect_container").html(data);
    $(".backdrop").fadeIn(300);
    $("#slide_inspect_container").fadeIn(300);

  })
});

$('body').on('click', '.edit-slide', function(event) {
  event.preventDefault();
  var id = $(this).attr('data-id');
  $.ajax({
    url: '/slides/'+ id +'/get_partial',
    data: {type: 'edit'},
  })
  .done(function(data) {
    $("#slide_edit_container").html(data);
    $(".backdrop").fadeIn(300);
    $("#slide_edit_container").fadeIn(300);
  })
});

$('body').on('click', '.delete-slide', function(event) {
  event.preventDefault();
  var id = $(this).attr('data-id');
  $.ajax({
    url: '/slides/'+ id +'/get_partial',
    data: {type: 'delete'},
  })
  .done(function(data) {
    $("#slide_delete_container").html(data);
    $(".backdrop").fadeIn(300);
    $("#slide_delete_container").fadeIn(300);
  })
});

$('body').on('click', '.see-this-slide', function(event) {
  event.preventDefault();
  var id = $(this).attr('data-id');
  $.ajax({
    url: '/slides/'+ id +'/get_partial',
    data: {type: 'show'},
  })
  .done(function(data) {
    $("#pose_window_container").html(data);
    $(".backdrop").fadeIn(300);
    $("#pose_window_container").fadeIn(300);
  })
});


// draw a set and show slideshow

  $('body').on('click', '.launch-study', function(event) {
    event.preventDefault();
    $(".backdrop").fadeIn(400, function() {
      $(".start-modal").fadeIn(300, function() {});
    });
  });

  $('body').on('click', '#start-draw-set', function(event) {
    event.preventDefault();
    $('form.launch-set').trigger('submit');
  });

  $('body').on('submit', 'form.launch-set', function(event) {
    event.preventDefault();
    $.ajax({
      url: $(this).attr('action'),
      data: $(this).serialize(),
    })
    .done(function(data) {
      var html = data;
      $("#pose_window_container").html(html);
      $('.start-modal').fadeOut(300, function() {});
    })

      $('#pose_window_container').fadeIn(300, function() {});
  });

    //  draw from random set
  $('body').on('click', '#random-set-menu', function(event) {
    event.preventDefault();
    // console.log('menu')
    // $("#random-sets").fadeIn(1000, function() {
    // });
  });

  $('body').on('click', '.draw-random-set', function(event) {
    event.preventDefault();
    length = $(this).attr('length');
    total = $(this).attr('total');
    $.ajax({
      url: '/slideshows/draw_set_random',
      data: {num: total, pose_l: length},
    })
    .done(function(data) {
      var html = data;
      $("#pose_window_container").html(html);
      $('.start-modal').fadeOut(300, function() {});
    })

      $('#pose_window_container').fadeIn(300, function() {});
  });

  // faq

  $('body').on('click', '.faq-pop', function(event) {
    event.preventDefault();
    $.ajax({
      url: '/home/get_faq',
    })
    .done(function(data) {
      $("#faq-container").html(data)
    })

    $("#faq-container").fadeIn(400, function() {

    });
    $(".backdrop").fadeIn(200, function() {

    });
  });

// update slide show form

$("body").on('click', '#update-this-slide', function(event) {
  event.preventDefault();
  $("#update-slide-form").trigger('submit');
});

$('body').on('submit', '#update-slide-form', function(event) {
  event.preventDefault();
  var path = $(this).attr('action');
  $.ajax({
    url: path,
    type: 'PATCH',
    data: $(this).serialize(),
  })
  .done(function(data) {
    $("#update-slide-form").trigger('reset');
    $.ajax({
      url: '/slides/'+data.id+'/get_partial',
      data: {type: 'edit'},
    })
    .done(function(data_s) {
      $("#slide_edit_container").html(data_s);
    })
  })
});

// delete a slide
$('body').on('click', '.confirm-deletion', function(event) {
  event.preventDefault();
  var id = $(this).attr('data-id');
  $("#slide_"+id).fadeOut(500);
  $.ajax({
    url: '/slides/' + id + '/destroy_this_slide',
    type: 'DELETE',
  })
  .done(function(data) {
  })

  $(".backdrop").trigger('click');

});

var li_interval;

$('body').on('mouseenter', 'ul.slideshow_lists li', function(event) {
  $(this).find('.ss_info').fadeIn(500, function() {});
  var that = $(this);
  var id = $(this).attr('data-id');

  li_interval = setInterval(function(){
    $.ajax({
      url: '/slideshows/'+id+'/get_image_slide_show',
    })
    .done(function(data) {
      var new_url = data.thumb_url
      that.fadeOut('500', function() {
        that.css('background-image', 'url('+new_url+')');
        that.fadeIn(500, function() {

        });
      });
    })
  },1000);

  $(this).css('opacity', '1');
});

$('body').on('mouseleave', 'ul.slideshow_lists li', function(event) {
  $(this).find('.ss_info').fadeOut(500, function() {});
  $(this).css('opacity', '.7');
  clearInterval(li_interval);
});


// slide show moving carosel for brose tags


$('body').on('mouseenter', 'ul.slideshow_lists_tags li', function(event) {
  $(this).find('.ss_info').fadeIn(500, function() {});
  var that = $(this);
  var id = $(this).attr('data-id');

});

$('body').on('mouseleave', 'ul.slideshow_lists_tags li', function(event) {
  $(this).find('.ss_info').fadeOut(500, function() {});
  // clearInterval(li_interval);
});


$('body').on('click', '.add-a-new-picture', function(event) {
  event.preventDefault();
  $('.backdrop').fadeIn(400, function() {
    $('.upload-modal-pic').slideDown(300, function() {});
  });
});

$('body').on('click', '.add-a-new-title', function(event) {
  event.preventDefault();
  $('.title-modal').fadeIn(300, function() {});
  $('.backdrop').fadeIn(600, function() {});
});

$('body').on('click', '.add-a-new-tags', function(event) {
  event.preventDefault();
  $('.tags-modal').fadeIn(300, function() {});
  $('.backdrop').fadeIn(600, function() {});
});

$('body').on('click', '.hide-right-menu', function(event) {
  event.preventDefault();
  $(".right-menu").slideUp(400, function(){
    $(".show-menu").slideDown(400);
  });
})

$('body').on('click', '.show-right-menu', function(event) {
  event.preventDefault();
  $(".show-menu").slideUp(400, function(){
    $(".right-menu").slideDown(400);
  });
});


// screen load

function checkVisible( elm, evalType ) {
    evalType = evalType || "visible";

    var vpH = $(window).height(), // Viewport Height
        st = $(window).scrollTop(), // Scroll Top
        y = $(elm).offset().top,
        elementHeight = $(elm).height();

    if (evalType === "visible") return ((y < (vpH + st)) && (y > (st - elementHeight)));
    if (evalType === "above") return ((y < (vpH + st)));
}



$(window).scroll(function(event) {
  appear();
});

appear();

$.each($('.slideshow_lists li'), function(index, val) {
  var id_class = val.attributes.class.value;
  var element = $('.' + id_class);
  var randTop = Math.floor((Math.random() * 300) + 100);
  element.css('top', randTop);
});

function appear() {
  $.each($('.slideshow_lists li'), function(index, val) {
    var id_class = val.attributes.class.value
    var element = $('.' + id_class)
    if ( checkVisible(element, 'visible') ) {
      element.animate({'opacity': .7, 'top': 0}, 1000)
    };
  });
}