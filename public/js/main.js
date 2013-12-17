$(function() {

  window.$uri = undefined;

  /* Lightbox function */
  var $lightbox = function(contents, width, height) {
    var width  = width  || 600;
    var height = height || 500;
    var $html  = $('<div id="lightbox-outer"> <div id="lightbox"><span class="close">x</span></div> </div>');
   
    $html.find('#lightbox')
      .css({
        left: ($(window).width() - width) / 2,
        top: (($(window).scrollTop() + ($(window).height())) - height) /2,
        width: width,
        height: height
        })
      .append(contents);

    $html
      .insertBefore('#outer-wrapper')
      .fadeIn('fast')
      .find('#lightbox')
        .fadeIn('fast');

    $('.close').on('click', function() {
      $html.fadeOut('fast', function(){
        $html.remove();
      });
    });
  };
  /* end of lightbox function */

  /* Response function */
  var $response = function() {
    var responses           = [
      "<div class='response no'>NO! <a href='/status/no'>(why?)</a></div>",
      "<div class='response maybe'>MAYBE? <a href='/status/maybe'>(why)</a></div>",
      "<div class='response not-sure'>NOT SURE! <a href='/status/not_sure'>(why?)</a></div>",
      "<div class='response yes'>YES! <a href='/status/yes'>(read more)</a></div>",
     
      "<div class='response no'>ERROR! <a onclick='javascript:void(0);'>(please try again)</a></div>"
    ];    
    Array.prototype.inArray = function(needle) {
      var exists = false;
      this.forEach(function(e) {
        if (e === needle) {
          exists = true;
        }
      });
      return exists;
    };

    var images   = ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'tiff'];
        filename = $uri.filename() || undefined;
    var ext      = $uri.suffix()   || undefined;
    
    var inject = function(res) {
    $('.loading').fadeOut('fast', function() {
      $('#animate').animate({
          left: "0"
       }, 'slow', function() {
          $('#box').animate({top: '57px'}, 455, function() {
            $(res).insertBefore('#box');
          }); 
        });
      });   
    };
    $.ajax({
      url:      document.href,
      type:     "POST",
      dataType: 'json',
      data:     {async: true, url: $uri.toString()},
      timeout:  15 * 1000,
      dataType: 'json',
    }).done(function(data) {
      inject(responses[data.status]);      
    }).fail(function() {
      inject(responses[4]);
    }); 
  };
  /* end of Response function */

  /* URI Validation */
  (function(window, document) {
    $('#search').on('keyup blur focusout', function(e) {
        $(this).next().attr('style', '');
        var url   = window.$uri = new URI($(this).val());
        var proto = url._parts.protocol,
          host    = url._parts.domain,
          errors  = false;
      if (proto && !proto.match(/^https?$/)) { 
        errors = true; 
      }
      if (!url.is('absolute')) { errors = true; }
      if (!url.is('url')) { errors      = true; }

      if ($(this).val().length > 0 && errors == true) {
        $(this).next().addClass('error');
      } else {
        $(this).next().removeClass('error');
      }
    });
    // the empty case
    $('#search + .button').click(function() {
      if ($(this).prev().val().length === 0) {
        var self = this;
        $(self).css('background', '#e74c3c');
        window.setTimeout(function() {
          $(self).css('background', '#2980b9');
        }, 900);
      }
    });
  })(window, document);
  /* End of URI Validation */

  /* Submit */
  (function() {
    var spinner = ['<ul class="spinner">',
      '<li></li>',
      '<li></li>',
      '<li></li>',
      '<li></li>',
      '</ul>'
    ].join("\n");
    $('form').submit(function(e) {
      e.preventDefault();
      var self = this;
      $('#box').animate({top: '0'}, 'slow');
      $('.response').remove();
      var errors = $('#search').val().length === 0 || $('.button').hasClass('error');
      if (!errors) {
        $('#animate').animate({
          left: "20px"
        }, 400, function() {
          $('.loading').html(spinner)
            .fadeIn(1000);
          $response();
        });
      }
    });
  })();
  /* end of Search */;
});