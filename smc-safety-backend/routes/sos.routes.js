const express = require('express');
const router = express.Router();
const sosController = require('../controllers/sos.controller');

router.post('/trigger', sosController.trigger);
router.get('/recent', sosController.getRecent);
router.put('/:sosId/status', sosController.updateStatus);

module.exports = router;
