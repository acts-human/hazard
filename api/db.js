'use strict';

const elasticsearch = require('elasticsearch');
const client = new elasticsearch.Client({
  host: process.env.ES_HOST,
  log: 'warning'
});

const db = {};

db.searchHazards = query => {
  return client.search({
    index: 'earthquake',
    q: query
  });
};

module.exports = db;
