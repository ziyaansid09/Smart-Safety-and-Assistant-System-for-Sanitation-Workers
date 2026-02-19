const express = require('express');
const router = express.Router();
const workersController = require('../controllers/workers.controller');

router.post('/checkin', workersController.checkin);
router.get('/all', workersController.getAllWorkers);
router.get('/:workerId', workersController.getWorkerById);
router.get('/:workerId/history', workersController.getWorkerHistory);

module.exports = router;
