library flutter_stripe;

import 'dart:async';

import 'ephemeral_key_manager.dart';
import 'model/card.dart';
import 'model/customer.dart';
import 'model/shipping_information.dart';
import 'model/source.dart';
import 'model/token.dart';
import 'stripe_api_handler.dart';

export 'card_number_formatter.dart';
export 'card_utils.dart';
export 'model/card.dart';
export 'model/customer.dart';
export 'model/shipping_information.dart';
export 'model/source.dart';
export 'model/token.dart';

class Stripe {
  final StripeApiHandler _apiHandler = new StripeApiHandler();

  final String publishableKey;
  String stripeAccount;

  Stripe(this.publishableKey) {
    _validateKey(publishableKey);
  }

  Future<Token> createCardToken(StripeCard card) async {
    final cardMap = card.toMap();
    final token = await _apiHandler.createToken(
        <String, dynamic>{Token.TYPE_CARD: cardMap}, publishableKey);
    return token;
  }

  Future<Token> createBankAccountToken(StripeCard card) async {
    return null;
  }

  static void _validateKey(String publishableKey) {
    if (publishableKey == null || publishableKey.isEmpty) {
      throw new Exception("Invalid Publishable Key: " +
          "You must use a valid publishable key to create a token.  " +
          "For more info, see https://stripe.com/docs/stripe.js.");
    }

    if (publishableKey.startsWith("sk_")) {
      throw new Exception("Invalid Publishable Key: " +
          "You are using a secret key to create a token, " +
          "instead of the publishable one. For more info, " +
          "see https://stripe.com/docs/stripe.js");
    }
  }
}

class CustomerSession {
  static final int KEY_REFRESH_BUFFER_IN_SECONDS = 30;

  static CustomerSession _instance;

  final StripeApiHandler _apiHandler = new StripeApiHandler();

  final EphemeralKeyManager _keyManager;

  ///
  CustomerSession._internal(this._keyManager);

  ///
  ///
  ///
  static void initCustomerSession(EphemeralKeyProvider provider) {
    if (_instance == null) {
      final manager =
          new EphemeralKeyManager(provider, KEY_REFRESH_BUFFER_IN_SECONDS);
      _instance = new CustomerSession._internal(manager);
    }
  }

  ///
  ///
  ///
  static void endCustomerSession() {
    _instance = null;
  }

  ///
  ///
  ///
  static CustomerSession get instance {
    if (_instance == null) {
      throw new Exception(
          "Attempted to get instance of CustomerSession without initialization.");
    }
    return _instance;
  }

  ///
  ///
  ///
  Future<Customer> retrieveCurrentCustomer() async {
    final key = await _keyManager.retrieveEphemeralKey();
    final customer =
        await _apiHandler.retrieveCustomer(key.customerId, key.secret);
    return customer;
  }

  ///
  ///
  ///
  Future<Source> addCustomerSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final source = await _apiHandler.addCustomerSource(
        key.customerId, sourceId, key.secret);
    return source;
  }

  ///
  ///
  ///
  Future<bool> deleteCustomerSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final deleted = await _apiHandler.deleteCustomerSource(
        key.customerId, sourceId, key.secret);
    return deleted;
  }

  ///
  ///
  ///
  Future<Customer> updateCustomerDefaultSource(String sourceId) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final customer = await _apiHandler.updateCustomerDefaultSource(
        key.customerId, sourceId, key.secret);
    return customer;
  }

  ///
  ///
  ///
  Future<Customer> updateCustomerShippingInformation(
      ShippingInformation shippingInfo) async {
    final key = await _keyManager.retrieveEphemeralKey();
    final customer = await _apiHandler.updateCustomerShippingInformation(
        key.customerId, shippingInfo, key.secret);
    return customer;
  }
}
