'use strict'

const request = require('request');
const api = {};
const endpoints = {
  hour: 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_hour.geojson',
  day: 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson'
};

let firstRun = true;

api.getFeatures = async () => {
  return new Promise((resolve, reject) => {
    let url = firstRun ? endpoints.day : endpoints.hour;
    firstRun = false;
    request(url, (err, res, body) => {
      if (err) {
        console.trace('Error:', err);
        reject(err);
      }
      let data = JSON.parse(body);
      resolve(data.features);
    });
  });
};

module.exports = api;
