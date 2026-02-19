const express = require('express');
const router = express.Router();
const drainageController = require('../controllers/drainage.controller');

router.get('/all', drainageController.getAll);
router.post('/add', drainageController.add);
router.get('/nearby', drainageController.getNearby);

module.exports = router;
