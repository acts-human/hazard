'use strict';
const api = {};

// GET /api/v1/hazards/search?q={query}
api.search = (req, res) => {
  let query = req.swagger.params.q.value;
  res.json({items: [query]});
};

module.exports = api
