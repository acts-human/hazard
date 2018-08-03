'use strict';

const elasticsearch = require('elasticsearch');
const client = new elasticsearch.Client({
  host: process.env.ES_HOST,
  log: 'warning'
});

const db = {};

let indexExists = async (name) => {
  return new Promise((resolve, reject) => {
    client.indices.exists({index: name}, (err, res, status) => {
      if (err) {
        console.trace('Error:', err);
        reject(err);
      } else {
        resolve(status == 200);
      }
    });
  });
};

let createIndex = async (name, mappings) => {
  let exists = await indexExists(name);
  if (exists) {
    return;
  }
  return new Promise((resolve, reject) => {
    client.indices.create({
      index: name,
      mappings: mappings
    }, (err, res, status) => {
      if (err) {
        console.trace(err);
        reject(err);
      } else {
        resolve(res);
      }
    });
  });
};

let putMapping = async (index, type, mapping) => {
  let exists = await indexExists(index);
  if (exists) {
    return;
  }
  return new Promise((resolve, reject) => {
    client.indices.putMapping({
      index: index,
      type: type,
      body: mapping
    }, (err, res, status) => {
      if (err) {
        console.trace('Error:', err);
        reject(err);
      } else {
        resolve(res);
      }
    });
  });
};

let deleteIndex = async name => {
  let exists = await indexExists(name);
  if (!exists) {
    return;
  }
  return new Promise((resolve, reject) => {
    client.indices.delete({
      index: name
    }, (err, res, status) => {
      if (err) {
        console.trace(err);
        reject(err);
      } else {
        resolve(res);
      }
    });
  });
};

db.migrate = async () => {
  console.log('migrating schema...');
  await deleteIndex('earthquake');
  await createIndex('earthquake');
  await putMapping('earthquake', 'earthquake', {
    properties: {
      magnitude: { type: "float" },
      place: { type: "string" },
      time: { type: "date" },
      depth: { type: "float" },
      location: { type: "geo_point" }
    }
  });
};

db.insertEarthquake = feature => {
  return new Promise((resolve, reject) => {
    client.index({
      index: 'earthquake',
      id: parseInt(feature.properties.code, 10),
      type: 'earthquake',
      body: {
        magnitude: feature.properties.mag,
        place: feature.properties.place,
        time: (new Date(feature.properties.time)).toJSON(),
        depth: feature.geometry.coordinates[2],
        location: {
          lat: feature.geometry.coordinates[0],
          lon: feature.geometry.coordinates[1]
        }
      }
    }, (err, res, status) => {
      if (err) {
        console.trace('Error:', err);
        reject(err);
      } else {
        console.log('inserted:', JSON.stringify(res));
        resolve(res);
      }
    });
  });
};

module.exports = db;
