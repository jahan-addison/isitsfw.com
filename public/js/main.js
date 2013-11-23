/*
  Can't help but feel they're some bad anti-patterns
  in this... to fix and optimize soon
 */
$(function() {

  /* URI Validation */
  (function(window, document) {
    // expose the URI object
    $('#search').on('keyup blur focusout', function() {
        $(this).next().attr('style', '');
        var url  = URI($(this).val()),
          proto  = url._parts.protocol,
          host   = url._parts.domain,
          errors = false;
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

  /* Search animation */
  (function() {
    var spinner = ['<ul class="spinner">',
      '<li></li>',
      '<li></li>',
      '<li></li>',
      '<li></li>',
      '</ul>'
      ].join("\n");
    var response = "<div class='response'>NO! <a href='#'>(why?)</a></div>"
    
    var res = function() {
      $('.loading').fadeOut('fast', function() {
        $('#animate').animate({
            left: "0"
         }, 'slow', function() {
          $('#box').animate({top: '50px'}, 'slow', function() {
            $(response).insertBefore('#box');
          });
         });
      });
    };
    
    $('#search + button').click(function() {
      var self = this;
      $('#box').animate({top: '0'}, 'slow');
      $('.response').remove();
      var errors = function() {
        return $('#search').val().length === 0 || $(self).hasClass('error');
      }();
      if (!errors) {
        $('#animate').animate({
          left: "20px"
        }, 455, function() {
          $('.loading').html(spinner)
            .fadeIn(1000);
          window.setTimeout(res, 4000);
        });
      }
    });
  })();
  /* end of Search animation */
});