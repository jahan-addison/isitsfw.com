$(function() {

  window.$uri = undefined;

  Array.inside = function (haystack, needle) {
    for (var i = 0; i < haystack.length; i++) {
      if (typeof haystack[i] === "object") {
        if (Array.inside(haystack[i], needle)) {
          return true;
        }
      }
      if (haystack[i] == needle) {
        return true;
      }
    }
    return false;
  };

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
     
      "<div class='response no'>ERROR! <a href='/'>(please try again)</a></div>"
    ];    

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
    }).always(function() {
      window.setTimeout(function() {
        running = false;        
      }, 3000)
    })
  };
  /* end of Response function */

  /* URI Validation */
  (function(window, document) {
    $('#search').on('keyup blur focusout', function(e) {
      // prefix tree
      /*
      var trie  = [
        'h', 'ht', 'htt', 'http', 
          ['https', 'https:', 'https:/', 'https://'], 
          ['http:', 'http:/', 'http://']
      ];
      var str    = $(this).val(),
          self   = this;
      if (str.length && !str.match(/^https?\:\/{2}/) ) { 
        if (!Array.inside(trie, str.substr(0, 'https://'.length))) {
          $(self).val("http://" + str);
          window.setTimeout(function() {
            $(self).trigger('keyup');
          }, 200);
        }
      }
      */
      /*
      if ($(this).val().length > 0 && errors == true) {
        $(this).next().addClass('error');
      } else {
        $(this).next().removeClass('error');
      }
      */
    });
  })(window, document);
  /* End of URI Validation */

  /* Submit */
  var running = false;
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
      if (running) {
        return false;
      }
      var input = $('#search');
      $('#box').animate({top: '0'}, 'slow');
      $('.response').remove();
      if (input.val().length === 0) {
        $('.button').css('background', '#e74c3c');
        window.setTimeout(function() {
          $('.button').css('background', '#2980b9');
        }, 900);
        return false;
      }
      running = true;
      if (!input.val().match(/^https?\:\/\//)) {
        input.val("http://" + input.val());
      }
      var errors = false;
      var url    = window.$uri = new URI(input.val());
      var proto = url._parts.protocol,
          host    = url._parts.domain;
      if (!url.is('absolute')) { errors = true; }
      if (!url.is('url')) { errors      = true; }
      if (errors) {
        running = false;
        $('.button').css('background', '#e74c3c');
        window.setTimeout(function() {
          $('.button').css('background', '#2980b9');
        }, 900);
        return false;
      }
      var self = this;
      if (!errors) {
        $('#animate').animate({
          left: "20px"
        }, 400, function() {
          $('.loading').html(spinner)
            .fadeIn(1000);
          $response();
        });
      }
      return false;
    });
  })();
  /* end of Search */;
});