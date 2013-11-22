$(function() {

  /* URI Validation */
  (function(window, document) {
    // expose the URI object
    $('#search').on('keyup blur focusout', function() {
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
  })(window, document);
  /* End of URI Validation */

  /* Search animation */
  (function() {
    var spinner = "<div class='pre-loader'></div>";
    var response = [
      "<div class='response'>",
      "",
      "</div>"
    ].join();
    /*
    var res = function() {
      $('loading').fadeOut('slow', function() {
        $('#animate').animate({
            left: "0"
         }, 'slow', function() {
          $('#box').animate({top: '50px'}, function() {

          })
         });
      });
    };
    */
    $('#search + button').click(function() {
      var self = this;
      var errors = function() {
        return $('#search').val().length === 0 || $(self).hasClass('error');
      }();
      if (!errors) {
        $('#animate').animate({
          left: "20px"
        }, 'slow', function() {
          $('.loading').html(spinner)
            .fadeIn('slow');
        });
      }
    });
  })();
  /* end of Search animation */
});