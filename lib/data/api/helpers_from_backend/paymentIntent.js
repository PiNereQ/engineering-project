// POST /payments/create-payment-intent
// POST /payments/confirm-payment

import express from 'express';
import Stripe from 'stripe';
import { blockListingTemporarily, unblockListingAfterFailure, deactivateListing } from './listingService.js';
import { createTransaction } from './transactionService.js';

const router = express.Router();

// YOUR SECRET KEY - stored ONLY on server
const stripe = new Stripe("sk_test_51RZ6Tm4DImOdy65uBFzh0SroA2FUBxuk5gLX6pq8cNnjdnUjys2uj2ioPZvq3SYUornlg9poak2ypcvwLATsAD5F007SPagDrl");  

/**
 * POST /payments/create-payment-intent
 * Creates a Stripe PaymentIntent and blocks the listing temporarily
 */
router.post('/create-payment-intent', async (req, res) => {
  try {
    const { amount, listingId } = req.body;

    if (!amount) {
      return res.status(400).json({ error: 'Amount is required' });
    }

    // Stripe minimum for PLN is 200 (2.00 PLN)
    if (amount < 200) {
      return res.status(400).json({ error: 'Amount must be at least 2.00 PLN' });
    }

    // Block listing temporarily to prevent other buyers from purchasing
    if (listingId) {
      await blockListingTemporarily(listingId);
    }

    // Create PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: 'pln',
      automatic_payment_methods: { enabled: true },
      metadata: {
        listingId: listingId || 'unknown',
      },
    });

    res.json({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });

  } catch (err) {
    console.error('Payment Intent Creation Error:', err);
    res.status(500).json({ error: err.message || 'Payment intent creation failed' });
  }
});

/**
 * POST /payments/confirm-payment
 * Confirms successful payment and creates transaction
 * Expected body: { paymentIntentId, listingId, couponId, buyerId, sellerId, price, isMultipleUse }
 */
router.post('/confirm-payment', async (req, res) => {
  try {
    const { paymentIntentId, listingId, couponId, buyerId, sellerId, price, isMultipleUse } = req.body;

    // Validate required fields
    if (!paymentIntentId || !listingId || !couponId || !buyerId || !sellerId || !price) {
      return res.status(400).json({
        error: 'Missing required fields: paymentIntentId, listingId, couponId, buyerId, sellerId, price',
      });
    }

    // Verify payment was successful with Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
    
    if (paymentIntent.status !== 'succeeded') {
      // Payment failed - unblock the listing
      await unblockListingAfterFailure(listingId);
      return res.status(400).json({ 
        error: `Payment not successful. Status: ${paymentIntent.status}` 
      });
    }

    // Payment succeeded - create transaction
    const transaction = await createTransaction({
      couponId,
      listingId,
      buyerId,
      sellerId,
      price,
    });

    // Deactivate listing if not multiple use
    await deactivateListing(listingId, isMultipleUse);

    res.status(201).json({
      success: true,
      message: 'Payment confirmed and transaction created',
      transaction,
    });

  } catch (err) {
    console.error('Payment Confirmation Error:', err);
    res.status(500).json({ error: err.message || 'Payment confirmation failed' });
  }
});

/**
 * POST /payments/cancel-payment
 * Cancels payment and unblocks the listing
 * Expected body: { listingId }
 */
router.post('/cancel-payment', async (req, res) => {
  try {
    const { listingId } = req.body;

    if (!listingId) {
      return res.status(400).json({ error: 'listingId is required' });
    }

    // Unblock the listing
    await unblockListingAfterFailure(listingId);

    res.json({
      success: true,
      message: 'Payment cancelled and listing unblocked',
    });

  } catch (err) {
    console.error('Payment Cancellation Error:', err);
    res.status(500).json({ error: err.message || 'Payment cancellation failed' });
  }
});

export default router;
