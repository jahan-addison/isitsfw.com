var should = require('chai').should(),
    fs  = require('fs'),
    assert = require('assert'),
    path = require('path');

var rest = require('restler');
console.log('YES:');
describe('YES', function() {
  describe('IMAGES', function() {
    it ('should acquire file', function() {
      files = fs.readdirSync('./YES/IMAGES/');
      files.forEach(function(e) {
        describe('file', function(){
          it('should return status code 3', function(done){
            this.timeout(15000);
            rest.post('http://isitsfw.com:8000', {
              data: { async: true, url: 'http://isitsfw.com:8000/test/YES/IMAGES/' + encodeURIComponent(e) }, timeout: 15000
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
