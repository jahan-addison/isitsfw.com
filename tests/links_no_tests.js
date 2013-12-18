var should = require('chai').should(),
    fs  = require('fs'),
    readline = require('readline');
    path = require('path');

var rest = require('restler');
console.log('NO:');
describe('NO', function() {
  describe('LINKS', function() {
    it ('should read link', function() {
        var rd = readline.createInterface({
            input: fs.createReadStream('./NO/LINKS/links.txt'),
            output: process.stdout,
            terminal: false
        });
        rd.on('line', function(line) {
        describe('file', function(){
          it('should return status code 0', function(done){
            this.timeout(15000);
            console.log(line);
            rest.post('http://isitsfw.com:8000', {
              data: { async: true, url: encodeURI(line) }, timeout: 15000
            }).on('complete', function(data, response) {
              console.log(data);
              if (data.status !== 0) {
                throw new Error(line);
              }
              done();
            });
          });
        });
      });
    });
  });
});
