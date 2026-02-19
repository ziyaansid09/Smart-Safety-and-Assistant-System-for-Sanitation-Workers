const express = require('express');
const router = express.Router();
const chatbotController = require('../controllers/chatbot.controller');

router.post('/query', chatbotController.query);

module.exports = router;
