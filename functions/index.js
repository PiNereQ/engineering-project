const functions = require("firebase-functions");
const Stripe = require("stripe");

const stripe = new Stripe(functions.config().stripe.secret, {
  apiVersion: "2025-05-28.basil",
});

exports.createPaymentIntent = functions.region("europe-west1").https.onRequest(async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount) {
      res.status(400).send({ error: "Amount is required" });
      return;
    }
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: "pln",
    });
    res.send({ clientSecret: paymentIntent.client_secret });
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
});
