const express = require('express')
const router = express.Router()
const userController = require('../controllers/user.controller')
const asyncHandler = require('../utils/asyncHandler')
const { checkAuth } = require('../middleware/authMiddleware')

router.get('/get-user', checkAuth, asyncHandler(userController.getUser))

module.exports = router