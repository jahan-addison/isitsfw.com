$(function() {

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
      "<div class='response no'>NO! <a href='#'>(why?)</a></div>",
      "<div class='response maybe'>MAYBE? <a href='#'>(more options)</a></div>",
      "<div class='response not-sure'>NOT SURE! <a href='#'>(why?)</a></div>",
      "<div class='response yes'>YES! <a href='#'>(why?)</a></div>"
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

    console.log(ext);

    $('.loading').fadeOut('fast', function() {
      $('#animate').animate({
          left: "0"
       }, 'slow', function() {
        // images
        if (ext && images.inArray(ext)) {
          $lightbox(ext);
        } 
        // some other file type
        else if (ext) {
          $('#box').animate({top: '57px'}, 455, function() {
            $(responses[2]).insertBefore('#box');
          });          
        }
        // any thing else
        else
        {
          $('#box').animate({top: '57px'}, 455, function() {
            $(responses[0]).insertBefore('#box');
          });
        }
       });
    });    
  };
  /* end of Response function */

  /* URI Validation */
  (function(window, document) {
    $('#search').on('keyup blur focusout', function(e) {
        $(this).next().attr('style', '');
        if (e.which === 13) {
          $('#search + button').click();
          return false;
        }
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
    $('#search + button').click(function() {
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

  /* Search */
  (function() {
    var spinner = ['<ul class="spinner">',
      '<li></li>',
      '<li></li>',
      '<li></li>',
      '<li></li>',
      '</ul>'
    ].join("\n");
    $('#search + button').click(function() {
      var self = this;
      $('#box').animate({top: '0'}, 'slow');
      $('.response').remove();
      var errors = $('#search').val().length === 0 || $(self).hasClass('error');
      if (!errors) {
        $('#animate').animate({
          left: "20px"
        }, 455, function() {
          $('.loading').html(spinner)
            .fadeIn(1000);
          window.setTimeout($response, 7500);
        });
      }
    });
  })();
  /* end of Search */;
});