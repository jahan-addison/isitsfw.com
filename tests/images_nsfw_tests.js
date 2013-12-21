var should = require('chai').should(),
    fs  = require('fs'),
    assert = require('assert'),
    path = require('path');

var rest = require('restler');
describe('NO', function() {
  describe('IMAGES', function() {
    it ('should acquire file', function() {
      files = fs.readdirSync( __dirname + '/NO/IMAGES/');
      files.forEach(function(e) {
        describe('file', function(){
          it('should return status code 0', function(done){
            this.timeout(15000);
            rest.post('http://soliloq.uy:4567', {
              data: { async: true, url: 'http://soliloq.uy:4567/test/NO/IMAGES/' + encodeURIComponent(e) }, timeout: 15000
            }).on('complete', function(data, response) {
              if (data.status !== 0) {
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
