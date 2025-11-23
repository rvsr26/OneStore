const express = require("express");
const Razorpay = require("razorpay");
const cors = require("cors");
const crypto = require("crypto");
const bodyParser = require("body-parser");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// TODO: Replace with your actual Key ID and Secret from Razorpay Dashboard
const razorpay = new Razorpay({
  key_id: "rzp_test_12345ABCDE", 
  key_secret: "YOUR_ACTUAL_SECRET_HERE", 
});

app.post("/create-order", async (req, res) => {
  try {
    const options = {
      amount: req.body.amount, // Amount in paise
      currency: req.body.currency,
      receipt: "receipt_" + Math.random().toString(36).substring(7),
    };
    const order = await razorpay.orders.create(options);
    res.json(order);
  } catch (error) {
    res.status(500).send(error);
  }
});

app.post("/verify-payment", (req, res) => {
  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
  const secret = "YOUR_ACTUAL_SECRET_HERE"; // Must match the one above

  const generated_signature = crypto
    .createHmac("sha256", secret)
    .update(razorpay_order_id + "|" + razorpay_payment_id)
    .digest("hex");

  if (generated_signature === razorpay_signature) {
    res.json({ status: "success" });
  } else {
    res.status(400).json({ status: "failure" });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));