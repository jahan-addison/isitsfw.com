$(function() {

  /* URI Validation */
  (function() {
    $('#search').on('keyup blur focusout', function() {
      var url    = URI($(this).val()),
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
  })();
  /* End of URI Validation */
});