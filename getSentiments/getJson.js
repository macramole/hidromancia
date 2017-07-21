// //1ro: obtener json
// var request = require('request');
var fs = require('fs');
// var URL = 'http://wefeel.csiro.au/api/emotions/primary/timepoints?start=1496354397000&end=1498946397000';//1ro de Junio hasta 1ro e Julio
//
// request(URL).pipe(fs.createWriteStream('sentiments.json'));
var json = require('./sentiments.json');

var joy = '';
var anger = '';
var love = '';
var sadness = '';
var fear = '';

for(var i = 0; i< json.length;i++){
  joy += json[i].counts.joy + '\n';
  anger += json[i].counts.anger + '\n';
  love += json[i].counts.love + '\n';
  sadness += json[i].counts.sadness + '\n';
  fear += json[i].counts.fear + '\n';
}

fs.writeFileSync('joy.txt',joy);
fs.writeFileSync('anger.txt',anger);
fs.writeFileSync('love.txt',love);
fs.writeFileSync('sadness.txt',sadness);
fs.writeFileSync('fear.txt',fear);
