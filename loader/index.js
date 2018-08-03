'use strict'

const dotenv = require('dotenv').config();
const program = require('commander');
const db = require('./db');
const usgs = require('./usgs');

program
  .version('0.1.0', '-v, --version')
  .option('-d, --daemon', 'Run as daemon')
  .option('-u, --update-schema', 'Destroy and recreate indices and mappings.')
  .parse(process.argv);

let main = async () => {
  try {
    if (program.updateSchema) {
      await db.migrate();
    }

    let features = await usgs.getFeatures();
    for (let feature of features) {
      db.insertEarthquake(feature);
    }
  } catch (err) {
    process.exit(1);
  }
};

if (program.daemon) {
  console.log('Running as daemon.');
  setTimeout(() => { // wait 20 seconds for first run
    main();
    setInterval(() => { // then run every 5 minutes
      main();
    }, 300000); 
  }, 20000); 
} else {
  main();
}
