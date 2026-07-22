require("dotenv").config();
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const functions = require("firebase-functions");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY); 

exports.createPaymentIntent =  onCall({ region: "asia-southeast1" }, async (request) => {
  try {
    const amount = request.data.amount; 
    const currency = request.data.currency || 'thb';

    if (!amount) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with an amount.');
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
      automatic_payment_methods: { enabled: true },
    });

    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});