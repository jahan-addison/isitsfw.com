$(function() {

  window.$uri = undefined;

  /* Bad file types */
  var $badFiles = [
    "doc", "docx", "log", "msg", "odt", "pages", "wpd", "wps", "gbr", "ged", "ibooks", "key", "keychain", "pps", "ppt", "pptx", "sdf",
    "tar", "tax2012", "aif", "iff", "m3u", "m4a", "mid", "mp3", "mpa", "ra", "wav", "wma", "3g2", "3gp", "asf", "asx", "avi", "flv", "m4v", "mov", "mp4",
    "mpg", "rm", "srt", "swf", "vob", "wmv", "3dm", "3ds", "max", "obj", "bmp", "dds",
    "psd", "pspimage", "tga", "thm", "tif",  "yuv", "ai", "eps", "ps", "svg", "indd", "pct", "pdf", "xlr", "xls", "xlsx", "accdb", "db", 
    "pdb", "apk", "app", "bat", "cgi", "com", "exe", "gadget", "jar", "pif", "vb",
    "wsf", "dem", "gam", "nes", "rom", "sav", "dwg", "dxf", "gpx", "kml", "kmz", 
    "fnt", "fon", "otf", "ttf", "cab", "cpl", "cur", "deskthemepack", "dll", "dmp", 
    "icns", "ico", "lnk", "sys", "cfg", "ini", "prf", "hqx", "mim", "uue", "7z", "cbr",
    "deb", "gz", "pkg", "rar", "rpm", "sitx", "tar.gz", "zip", "zipx", "bin", "cue", "dmg",
    "iso", "dbf", "mdb", "plugin", "mdf", "toast", "drv", "vcd", 
    "xcodeproj", "bak", "tmp", "crdownload", "ics", "msi", "part", "torrent"
  ];
  /* End of bad file types */

  /* Deferred image load function */
  $.loadImage = function(url) {
    // Define a "worker" function that should eventually resolve or reject the deferred object.
    var loadImage = function(deferred) {
      var image = new Image();
       
      image.onload = loaded;
      image.onerror = errored; 
      image.onabort = errored; 
      image.crossOrigin = "Anonymous"; 
      image.src = url;
       
      function loaded() {
        unbindEvents();
        deferred.resolve(image);
      }
      function errored() {
        unbindEvents();
        deferred.reject(image);
      }
      function unbindEvents() {
        image.onload = null;
        image.onerror = null;
        image.onabort = null;
      }
    };

    return $.Deferred(loadImage).promise();
  };
  /* end of deferred image load function */

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

  /* Image response */
  var $imageResponse = function(uri) {
    var dfd    = new jQuery.Deferred();
    var status = {status: 0};

    if ($('html').hasClass('ie')) {
      dfd.reject(false);
    }

    $.loadImage($uri.toString())
      .done(function(image) {
        result(image);
      })
      .fail(function(image) {
        dfd.reject(image);
      });

    var result = function(image) {
      $('#Image').remove();
      image.id            = "Image";
      $('body').append(image);
      image.style.display = "none";
      nude.load(image);
      $('body').append(image);
      nude.scan(function(result) {
        if (result === false) {
          dfd.resolve(result);
        } else if (result === true) {
          // nudity detected!
          dfd.resolve(result);
        }
      });
    };
    return dfd.promise();
  };
  /* End of image response */

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

    // Image
    if (ext && images.inArray(ext)) {
        $.when( $imageResponse($uri) ).then(
          function (status) {
            if (!status) {
              inject(responses[3]);
            } else {
              inject(responses[0]);
            }
          },
          function (status) {
            // We need to try another method, now
            alert("status 2" + status);
          }
      );
    } 
    // bad file
    else if (ext && $badFiles.inArray(ext)) {
      inject(responses[2]);
    }
    // something else
    else
    {
      inject(responses[0]);
    }  
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

  /* Submit */
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
        }, 400, function() {
          $('.loading').html(spinner)
            .fadeIn(1000);
          window.setTimeout($response, 1000);
        });
      }
    });
  })();
  /* end of Search */;
});