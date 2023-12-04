class ApiConst {
  static const String baseUrl = "https://arthurmaurice.com/api/";

  ///auth
  static const String login = "login";
  static const String logout = "user/logout";
  static const String register = "register";
  static const String sendMobileVerification = "user/resend-verify?type=phone";
  static const String sendEmailVerification = "user/resend-verify?type=email";
  static const String verifyEmail = "user/verify-email";
  static const String verifyMobile = "user/verify-sms";
  static const String forgotPassword = "password/email";
  static const String forgotPasswordSubmit = "submit-password-otp";
  static const String getUser = "user";
  static const String updateProfile = "user/update-profile";
  static const String updatePassword = "user/change-password";
  static const String updateProfileImage = "user/update-profile-image";

  static const String bidHistory = "user/bids";
  static const String winnigBids = "user/winning-bids";
  static const String refferals = "user/get-referrals";

  ///dashboard
  static const String dashboard = "dashboard";
  static const String search = "search";
  static const String liveAuctionProducts = "live-auction-products";
  static const String upcomingAuctionProducts = "upcoming-auction-products";
  static const String closedAuctionProducts = "closed-auction-products";

  ///category
  static const String categories = "categories";
  static const String categoryProducts = "category-products";

  ///auction
  static const String auction = "auction";
  static const String placeBid = "place-bid";
  static const String productBids = "product-bids";
  static const String productAllRatings = "all-ratings";
  static const String rateProduct = "rate-product";

  ///transaction
  static const String getTransactions = "user/transactions";
  static const String getDeposits = "user/deposit/history";
}
