const User = require("../models/user.model");
const ExpressError = require("../utils/ExpressError");

exports.getUser = async (req, res) => {
  const user = await User.findById(req.user._id).select('-password'); // Exclude password field
  if (!user) throw new ExpressError(400, false, 'User was not found')
  res.status(200).json({ success: true, user });
}