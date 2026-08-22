const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");

const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.createPaymentIntent = onCall(
  {
    region: "asia-southeast1",
    secrets: ["STRIPE_SECRET_KEY"],
    invoker: "public",
  },
  async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const organizerId = request.data.organizerId;
    const email = request.data.email;
    const amount = request.data.amount;
    const currency = request.data.currency || "thb";

    if (!organizerId) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with an organizerId.",
      );
    }
    if (!Number.isInteger(amount) || amount <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with a positive integer amount in the smallest currency unit.",
      );
    }
    if (userId === organizerId) {
      throw new HttpsError(
        "invalid-argument",
        "You cannot purchase a ticket for your own event.",
      );
    }

    try {
      const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

      const organizerDoc = await db.collection("users").doc(organizerId).get();
      if (!organizerDoc.exists) {
        throw new HttpsError("not-found", "Organizer not found.");
      }

      const stripeAccountId = organizerDoc.data().stripeAccountId;
      if (!stripeAccountId) {
        throw new HttpsError(
          "failed-precondition",
          "The seller has not connected their Stripe account.",
        );
      }

      // Calculate the platform profit and Stripe processing fee
      const applicationFeeAmount = Math.floor(amount * 0.07);
      const stripeProcessingFee = Math.floor(amount * 0.0365 + 10) * 1.07;
      const amountToSendToOrganizer = Math.floor(
        amount - applicationFeeAmount - stripeProcessingFee,
      );

      if (amountToSendToOrganizer <= 0) {
        throw new HttpsError(
          "invalid-argument",
          "The amount is too small to cover the platform and processing fees.",
        );
      }

      const paymentIntent = await stripe.paymentIntents.create({
        receipt_email: email,
        amount: amount,
        currency: currency,
        automatic_payment_methods: { enabled: true },
        transfer_data: {
          destination: stripeAccountId,
          amount: amountToSendToOrganizer,
        },
      });

      return {
        clientSecret: paymentIntent.client_secret,
      };
    } catch (error) {
      throw new HttpsError("internal", error.message);
    }
  },
);

exports.createStripeAccount = onCall(
  {
    region: "asia-southeast1",
    secrets: ["STRIPE_SECRET_KEY"],
    invoker: "public",
  },
  async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    try {
      const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

      const userRef = db.collection("users").doc(userId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw new HttpsError("not-found", "User not found.");
      }

      const userData = userDoc.data() ?? {};
      let accountId = userData.stripeAccountId;

      if (!accountId) {
        const account = await stripe.accounts.create({
          email: userData.email,
          type: "standard",
        });
        accountId = account.id;
        await userRef.update({ stripeAccountId: accountId });
      }

      const accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: "https://eventee.com/reauth",
        return_url: "https://eventee.com/return",
        type: "account_onboarding",
      });

      return { url: accountLink.url };
    } catch (error) {
      throw new HttpsError("internal", error.message);
    }
  },
);

exports.sendBookingPushNotification = onCall(
  {
    region: "asia-southeast1",
    invoker: "public",
  },
  async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    try {
      const title = request.data.title;
      const messageText = request.data.message;
      const channelId = request.data.channelId;

      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw new HttpsError("not-found", "User not found.");
      }

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) {
        throw new HttpsError(
          "failed-precondition",
          "`User does not have an active device token registration.",
        );
      }

      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: title,
          body: messageText,
        },
        android: {
          priority: "high",
          notification: {
            channelId: channelId,
            sound: "default",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          screen: "notification_history",
        },
      });

      return { success: true };
    } catch (e) {
      throw new HttpsError("internal", e.message);
    }
  },
);
