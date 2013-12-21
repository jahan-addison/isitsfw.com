var should = require('chai').should(),
    fs  = require('fs'),
    assert = require('assert'),
    path = require('path');

var rest = require('restler');
describe('YES', function() {
  describe('IMAGES', function() {
    it ('should acquire file', function() {
      files = fs.readdirSync( __dirname + '/YES/IMAGES/');
      files.forEach(function(e) {
        describe('file', function(){
          it('should return status code 3', function(done){
            this.timeout(15000);
            rest.post('http://soliloq.uy:4567', {
              data: { async: true, url: 'http://soliloq.uy:4567/test/YES/IMAGES/' + encodeURIComponent(e) }, timeout: 15000
            }).on('complete', function(data, response) {
              if (data.status !== 3) {
                throw new Error(e);
              }
              done();
            });
          });
        });
      });
    });
  });
});
