const express = require('express');
const router = express.Router();
const zonesController = require('../controllers/zones.controller');

router.get('/', zonesController.getAll);

module.exports = router;
