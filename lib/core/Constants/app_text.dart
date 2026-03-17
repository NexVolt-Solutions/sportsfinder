/// SportFinding App — Centralized Text Constants
/// All UI strings extracted from the app's screens.
library;

class AppText {
  AppText._();

  // ─── App Name ───────────────────────────────────────────────────────────────
  static const String appName = 'SportFinding';
  static const String noRouteFound = 'No Route Found';

  // ─── Onboarding / Welcome ────────────────────────────────────────────────────
  static const String welcomeBack = 'Welcome Back';
  static const String createAccount = 'Create Account';
  static const String joinSportFinding = 'Join SportFinding today';
  static const String onboardingTitle1 = 'Find Sports Near You';
  static const String onboardingTitle2 = 'Connect With Players';
  static const String onboardingTitle3 = 'Play and Improve';
  static const String onboardingDesc1 =
      'Discover nearby sports matches and players in your area.';
  static const String onboardingDesc2 =
      'Discover players and sports matches happening in your area.';
  static const String onboardingDesc3 =
      'Join games or invite players to matches.';
  static const String onboardingDesc4 =
      'Compete with players of your skill level and enjoy sports.';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String skipForNow = 'Skip for Now';
  static const String next = 'Next';
  static const String continueButton = 'Continue';

  // ─── Authentication ──────────────────────────────────────────────────────────
  static const String loginToContinue = 'Login to continue';
  static const String email = 'Email';
  static const String emailHint = 'user@gmail.com';
  static const String fullName = 'Full Name';
  static const String createPassword = 'Create Password';
  static const String confirmPassword = 'Confirm Password';
  static const String passwordHint = '********';
  static const String phoneNumber = 'Phone Number';
  static const String phoneHint = '+45 XX XX XX XX';
  static const String forgotPassword = 'Forget password?';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String continueWithGoogle = 'Continue with Google';
  static const String dontHaveAccount = "Don't have an account? Sign Up";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String iAgreeTo = 'I agree to the ';
  static const String agreeToTerms = 'Terms of Service ';
  static const String and = 'and ';
  static const String privacy = 'Privacy Policy';

  // ─── OTP / Verification ─────────────────────────────────────────────────────
  static const String verifyYourAccount = 'Verify Your Account';
  static const String enterVerificationCode =
      'Enter the 6-digit code that we have sent to your email';
  static const String didntReceiveCode = "Didn’t receive the code?";
  static const String resend = 'Resend';
  static const String timerExample = '02:30s';

  // ─── Location Permission ──────────────────────────────────────────────────────
  static const String allowLocationAccess = 'Allow Location Access';
  static const String allowLocationDesc =
      'Discover nearby sports matches and players in your area.';
  static const String allowLocation = 'Allow Location';

  // ─── Skill Level ─────────────────────────────────────────────────────────────
  static const String skillLevelTitle = "What's your skill level?";
  static const String skillLevelDesc =
      'This helps us find the right matches for you';
  static const String beginner = 'Beginner';
  static const String casualPlayer = 'Casual Player';
  static const String intermediate = 'Intermediate';
  static const String regularPlayer = 'Regular Player';
  static const String advanced = 'Advanced';
  static const String competitiveAthlete = 'Competitive Athlete';
  static const String any = 'Any';

  // ─── Choose Sports ────────────────────────────────────────────────────────────
  static const String chooseSportsTitle = 'Choose Your Sports';
  static const String chooseSportsDesc = 'Select the sports you enjoy playing.';

  // ─── Sports ──────────────────────────────────────────────────────────────────
  static const String football = 'Football';
  static const String basketball = 'Basketball';
  static const String tennis = 'Tennis';
  static const String volleyball = 'Volleyball';
  static const String cricket = 'Cricket';

  // ─── Bottom Navigation ────────────────────────────────────────────────────────
  static const String navMatches = 'Matches';
  static const String navDiscover = 'Discover';
  static const String navChat = 'Chat';
  static const String navHome = 'Home';
  static const String navProfile = 'Profile';

  // ─── Home / Dashboard ────────────────────────────────────────────────────────
  static const String goodEvening = 'Hey, Good Evening!';
  static const String findAMatch = 'Find a Match';
  static const String allUpcomingMatches = 'All Upcoming Matches';
  static const String viewAll = 'View All';
  static const String popularSports = 'Popular Sports';
  static const String searchSportsOrLocations = 'Search sports or locations...';
  static const String recentPlayers = 'Recent Players';
  static const String nearbyPlayers = 'Nearby Players';
  static const String recommendedPlayers = 'Recommended Players';

  // ─── Match Card / Listing ─────────────────────────────────────────────────────
  static const String seatsAvailable = 'Seats Available';
  static const String matchFull = 'Full';
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String km = 'km';

  // ─── Match Details / View Match ───────────────────────────────────────────────
  static const String matchOverview = 'Overview';
  static const String matchInvitePlayers = 'Invite Players';
  static const String matchLocation = 'Location';
  static const String matchDate = 'Date';
  static const String matchTime = 'Time';
  static const String matchSkillLevel = 'Skill Level';
  static const String matchPlayers = 'Players';
  static const String matchHost = 'Host';
  static const String aboutThisMatch = 'About this match';
  static const String participatedPlayers = 'Participated Players';
  static const String joinMatch = 'Join Match';
  static const String leaveMatch = 'Leave Match';
  static const String seeAllMembers = 'See All Members';

  static const String sampleMatchDescription =
      'Friendly basketball game at Central Park. All intermediate players welcome. '
      'Bring your own ball if possible. We usually play for about 2 hours.';

  // ─── Match Full Dialog ────────────────────────────────────────────────────────
  static const String matchIsFullTitle = 'Match is Full';
  static const String matchIsFullDialogTitle = 'Do you want to join a match?';
  static const String matchIsFullDesc =
      'This match has reached its maximum capacity. You can get notified if a spot opens up or explore matches.';
  static const String notifyIfSpotOpens = 'Notify me if spot opens';
  static const String viewSimilarMatches = 'View Similar Matches';

  // ─── Match Created ────────────────────────────────────────────────────────────
  static const String matchCreatedTitle = 'Match Created!';
  static const String matchCreatedDesc =
      'Your match is live. Share it with friends!';
  static const String shareMatch = 'Share Match';

  // ─── Create Match ─────────────────────────────────────────────────────────────
  static const String createMatchTitle = 'Create Match';
  static const String createMatchSubtitle =
      'Set up a new game for others to join.';
  static const String matchTitleLabel = 'Match Title';
  static const String matchTitleHint = 'Give your match a name';
  static const String sportTypeLabel = 'Sport Type';
  static const String sportTypeHint = 'e.g Basketball';
  static const String locationLabel = 'Location';
  static const String locationHint = 'Enter Location';
  static const String maximumPlayersLabel = 'Maximum Players';
  static const String maximumPlayersHint = 'e.g. 10';
  static const String skillLevelLabel = 'Skill Level';
  static const String skillLevelHint = 'Beginner / Intermediate / Advanced';
  static const String descriptionLabel = 'Description';
  static const String descriptionHint = 'Describe your match...';
  static const String dateLabel = 'Date';
  static const String dateHint = 'dd/mm/yyyy';
  static const String timeLabel = 'Time';
  static const String timeHint = '--:-- --';
  static const String invitePeople = 'Invite People';
  static const String createMatchButton = 'Create Match';

  // ─── Invite Players ───────────────────────────────────────────────────────────
  static const String invitePlayersTitle = 'Invite Players';
  static const String searchPlayersHint = 'Search players by name';
  static const String inviteFromContacts = 'Invite from Contacts';
  static const String shareInviteLink = 'Share Invite Link';
  static const String invite = 'Invite';
  static const String invited = 'Invited';
  static const String participant = 'Participant';
  static const String invitationSetTitle = 'Invitation Set';
  static const String invitationSetDesc =
      'You have sent the invitation to the other player wait until Accepted!';

  // ─── Match Invitation (Notification) ─────────────────────────────────────────
  static const String invitationAccept = 'Accept';
  static const String invitationDecline = 'Decline';
  static const String invitedToMatchDesc =
      'Rimsha invited you to join a basketball match';

  // ─── Discover ────────────────────────────────────────────────────────────────
  static const String discoverTitle = 'Discover';
  static const String searchMatchesHint = 'Search Matches';
  static const String discoverNearbyPlayers =
      'Discover nearby players in your area';

  // ─── Filters ─────────────────────────────────────────────────────────────────
  static const String filtersTitle = 'Filters';
  static const String sportTypeFilter = 'Sport Type';
  static const String distanceFromYou = 'Distance from you: 10 km';
  static const String skillLevelFilter = 'Skill Level';
  static const String timeFilter = 'Time';
  static const String filterReset = 'Reset';
  static const String filterApply = 'Apply';

  // ─── My Matches ──────────────────────────────────────────────────────────────
  static const String myMatchesTitle = 'My Matches';

  // ─── Notifications ───────────────────────────────────────────────────────────
  static const String notificationsTitle = 'Notifications';
  static const String notifToday = 'Today';
  static const String notifYesterday = 'Yesterday';
  static const String notifRimshaInvited =
      'Rimsha invited you to join a basketball match';
  static const String notifHinaJoined = 'Hina joined your match';
  static const String notifTaifLeft = 'Taif left your match';
  static const String notifMatchFull = 'Your basketball game is now full';
  static const String notifAlexStarted = 'Alex started the game';
  static const String pushNotificationEnabled = 'Push Notification enabled';

  // ─── Chat ────────────────────────────────────────────────────────────────────
  static const String chatTitle = 'Chat';
  static const String searchPlayersOrSportHint =
      'Search Players by name or sport';
  static const String typeAMessage = 'Type a message...';
  static const String online = 'Online';
  static const String sampleChatMessage1 =
      'Hey! Are you coming to the basketball game tonight?';
  static const String sampleChatMessage2 =
      "Yes! I'll be there at 7. Should I bring anything?";
  static const String sampleChatMessage3 = 'Can i bring a friend?';
  static const String sampleChatMessage4 =
      'Just bring a water bottle. We have the ball.';
  static const String sampleChatMessage5 = 'Thanks for organizing!';
  static const String sampleChatMessage6 = 'Perfect, see you there! 🏀';
  static const String sampleChatMessage7 = 'What should i bring?';
  static const String sampleChatMessage8 = 'See you at the game!';
  static const String sampleChatMessage9 = 'Great game yesterday!';

  // ─── Profile ─────────────────────────────────────────────────────────────────
  static const String profileTitle = 'Profile';
  static const String editProfileTitle = 'Edit Profile';
  static const String previewProfile = 'Preview your Profile';
  static const String previewProfileDesc =
      'See what your profile looks like to others';
  static const String followers = 'Followers';
  static const String following = 'Following';
  static const String matchesPlayed = 'Matches Played';
  static const String rating = 'Rating';
  static const String mySports = 'My Sports';
  static const String myAccount = 'My Account';
  static const String publicProfile = 'Public Profile';
  static const String notification = 'Notification';
  static const String termsOfService = 'Terms of Service';
  static const String readTerms = 'Read our terms of services';
  static const String privacyPolicy = 'Privacy Policy';
  static const String manageYourData = 'Manage your data';
  static const String contactUs = 'Contact Us';
  static const String contactUsDesc = 'Contact us from your phone';
  static const String manageYourProfile = 'Manage your Profile';
  static const String editYourProfile = 'Edit Your Profile';
  static const String follow = 'Follow';
  static const String message = 'Message';
  static const String inviteToMatch = 'Invite to Match';
  static const String saveChanges = 'Save Changes';
  static const String changePhoto = 'Change Photo';
  static const String bioLabel = 'Bio';
  static const String nameLabel = 'Name';
  static const String sampleBio = 'Passionate about sports and fitness.';
  static const String sampleBioLong =
      'Passionate athlete who loves team sports and meeting new players. Always up for a match! 🔥';

  // ─── Confirm Dialog ───────────────────────────────────────────────────────────
  static const String confirm = 'Confirm';
  static const String cancel = 'Cancel';

  // ─── Privacy Policy ───────────────────────────────────────────────────────────
  static const String privacyPolicyTitle = 'Privacy Policy – SportFinding';
  static const String privacyEffectiveDate = 'Effective Date: March 13, 2026';
  static const String privacyIntro =
      'We value your privacy and want you to feel safe while discovering sports matches and connecting with players. '
      'This Privacy Policy explains how we collect, use, and protect your information.';

  static const String privacySection1Title = '1. Information We Collect';
  static const String privacySection1Personal =
      'Personal Information: Name, email, phone number, password, profile photo, skill level, sports preferences.';
  static const String privacySection1Usage =
      'Usage Data: App interactions, matches joined/created, notifications, chat messages.';
  static const String privacySection1Location =
      'Location Data: To show nearby matches and players (only if you allow).';

  static const String privacySection2Title = '2. How We Use Your Information';
  static const String privacySection2Point1 =
      'To connect you with players and matches.';
  static const String privacySection2Point2 =
      'To send notifications about upcoming games, invitations, and updates.';
  static const String privacySection2Point3 =
      'To improve the app experience and provide personalized recommendations.';
  static const String privacySection2Point4 =
      'To maintain a secure environment (detect spam, abuse, or inappropriate behavior).';

  static const String privacySection3Title = '3. Private Following Feature';
  static const String privacySection3Point1 =
      'Users can follow others privately.';
  static const String privacySection3Point2 =
      'Only you can see your following and followers lists.';
  static const String privacySection3Point3 =
      'No other users can access someone else\'s followers or following.';

  static const String privacySection4Title = '4. Sharing Your Information';
  static const String privacySection4Point1 =
      'We do not sell or share your personal information with third parties for advertising.';
  static const String privacySection4Point2 =
      'Your profile info (name, avatar, skill level) is visible to other players for match participation.';
  static const String privacySection4Point3 =
      'Location is only shared to show nearby matches.';

  static const String privacySection5Title = '5. Security';
  static const String privacySection5Point1 =
      'We use encryption and secure servers to protect your data.';
  static const String privacySection5Point2 =
      'Keep your password safe; don\'t share it with others.';

  static const String privacySection6Title = '6. Your Choices';
  static const String privacySection6Point1 = 'You can disable notifications.';
  static const String privacySection6Point2 =
      'You can delete your account at any time, which removes your profile and data from our system.';

  static const String privacySection7Title = '7. Children\'s Privacy';
  static const String privacySection7Point1 =
      'Our app is not intended for children under 13.';

  static const String privacySection8Title = '8. Changes to Privacy Policy';
  static const String privacySection8Point1 =
      'We may update this policy occasionally. Updated versions will be posted in the app.';

  // ─── Terms of Service ─────────────────────────────────────────────────────────
  static const String tosTitle = 'Terms of Service – SportFinding';
  static const String tosEffectiveDate = 'Effective Date: March 13, 2026';
  static const String tosIntro = 'Welcome to SportFinding!';

  static const String tosSection1Title = '1. Acceptance of Terms';
  static const String tosSection1Point1 =
      'By using SportFinding, you agree to follow these Terms of Service. If you do not agree, please do not use the app.';

  static const String tosSection2Title = '2. Account';
  static const String tosSection2Point1 =
      'You must provide accurate information during registration.';
  static const String tosSection2Point2 = 'Keep your account secure.';
  static const String tosSection2Point3 =
      'You are responsible for activity under your account.';

  static const String tosSection3Title = '3. Creating and Joining Matches';
  static const String tosSection3Point1 = 'Hosts control when a game starts.';
  static const String tosSection3Point2 =
      'Hosts can remove players if needed before starting a match.';
  static const String tosSection3Point3 =
      'Only the host can officially start the game.';

  static const String tosSection4Title = '4. User Conduct';
  static const String tosSection4Point1 =
      'Respect other players. No harassment, discrimination, or offensive content.';
  static const String tosSection4Point2 =
      'No cheating or falsifying your skill level.';
  static const String tosSection4Point3 =
      'Do not share other users\' private information.';

  static const String tosSection5Title = '5. Private Following';
  static const String tosSection5Point1 = 'Following other users is private.';
  static const String tosSection5Point2 =
      'Do not attempt to access someone else\'s follow lists.';

  static const String tosSection6Title = '6. Content';
  static const String tosSection6Point1 =
      'Any content you post (profile, chat messages, match descriptions) must comply with these terms.';
  static const String tosSection6Point2 =
      'SportFinding may remove content violating the rules.';

  static const String tosSection7Title = '7. Liability';
  static const String tosSection7Point1 =
      'SportFinding is not responsible for injuries, disputes, or accidents during games.';
  static const String tosSection7Point2 =
      'Users join matches at their own risk.';

  static const String tosSection8Title = '8. Termination';
  static const String tosSection8Point1 =
      'We may suspend or terminate your account for violating these Terms.';
  static const String tosSection8Point2 =
      'You can delete your account anytime.';

  static const String tosSection9Title = '9. Changes';
  static const String tosSection9Point1 =
      'We may update these Terms. Continued use of the app means you accept the updates.';
}
