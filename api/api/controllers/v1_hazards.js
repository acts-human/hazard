'use strict';

const db = require('../../db');
const api = {};

// GET /api/v1/hazards/search?q={query}
api.search = (req, res) => {
  let query = req.swagger.params.q.value;
  db.searchHazards(query).then(data => {
    res.json(data);
  }).catch(err => {
    res.status(500).json(err);
  });
};

module.exports = api
