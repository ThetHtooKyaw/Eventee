require("dotenv").config();

const functions = require("firebase-functions");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY); 

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  try {
    // 1. Get the amount from the Flutter app (e.g., 2000 = $20.00)
    const { amount, currency } = data;

    // 2. Create a PaymentIntent on Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
      // 'automatic_payment_methods' handles cards, Apple Pay, Google Pay automatically
      automatic_payment_methods: { enabled: true },
    });

    // 3. Send the "client_secret" back to the Flutter app
    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    // If there is an error (like "Amount too small"), send it back to the phone
    throw new functions.https.HttpsError('internal', error.message);
  }
});