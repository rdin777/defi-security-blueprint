📋 Checklist: CEX Interface Audit (Web + Mobile App)
1. Authentication and Session Management
No.
Verification
Note
1.1
Is MFA (TOTP, SMS, hardware key) implemented?
Mandatory. Check for vulnerabilities during setup/disabling.
1.2
Are password guessing attempts handled correctly (rate limiting, blocking)?
Check via brute force.
1.3
Are sessions stored securely (HTTPOnly, Secure, SameSite)?
Check cookies.
1.4
Is there an automatic logout after inactivity?
Check time settings.
1.5
Are multiple devices/sessions handled correctly?
Check the ability to disconnect other sessions.
1.6
CSRF (Cross-Site Request Forgery) protection?
Check for the presence of CSRF tokens.
1.7
MFA authentication for critical actions (withdrawal, email changes)?
Must be mandatory.
2. Authorization and Access Control
No.
Check
Note
2.1
Are access rights (RBAC/ABAC) implemented correctly?
Check the privileges of regular/admin accounts.
2.2
Check for IDOR (Insecure Direct Object Reference)?
Try accessing other people's data by changing the ID in the URL/parameters.
2.3
Are API key actions restricted (permissions, IP whitelist)?
Check the API key settings.
2.4
Is user activity logging and auditing enabled?
Especially critical actions (exit, privilege changes).
3. Data Security and Privacy
No.
Check
Note
3.1
Is HTTPS Everywhere (HSTS) used?
Check headers.
3.2
Is sensitive data (passwords, 2FA keys) stored and transmitted securely?
Passwords — hashed (bcrypt/scrypt), 2FA — do not store in cleartext.
3.3
Is email/phone number changes handled correctly (login with old email, verification)?
Check for data leaks.
3.4
Are there any data leaks through DOM, LocalStorage, SessionStorage, or logs?
Check DevTools.
3.5
Does data processing comply with GDPR/CCPA requirements?
If applicable.
4. Web Security (Frontend)
No.
Check
Note
4.1
XSS (Cross-Site Scripting) Protection?
Check input fields (name, address, comments), data reflection.
4.2
Is CSP (Content Security Policy) configured correctly?
Restricts script execution sources.
4.3
Clickjacking Check?
Check X-Frame-Options and frame-ancestors headers.
4.4
Is file uploading (e.g., KYC documents) safe?
Type restrictions, antivirus, isolation.
4.5
Insecure Deserialization Check?
Rare, but can occur in custom data formats.
5. Mobile Security (Mobile App)
No.
Check
Note
5.1
Is SSL Pinning implemented correctly?
Protection against MITM attacks.
5.2
Are credentials stored securely (Keychain on iOS, Keystore on Android)?
Do not store in plain text.
5.3
Check for Root/Jailbreak detection?
Should the app be disabled on jailbroken devices.
5.4
Are screenshots processed correctly (e.g., during 2FA entry)?
Disable screenshots on critical screens.
5.5
Check for Side-Channel Attacks (Clipboard, Accessibility Services)?
Do not read/write unnecessary data.
5.6
Is secure logging used (no PII in logs)?
Check adb logcat (Android) / Console (iOS).
5.7
Checking for hardcoded API keys or sensitive strings in the binary?
Use strings, objdump, or jadx.
6. API Security
No.
Check
Note
6.1
Are all API endpoints protected by authentication?
Check for anonymous access.
6.2
Is request signature verification implemented correctly (if API keys are used)?
Signature, timestamp, nonce.
6.3
Rate Limiting?
Check for brute-force and DoS attacks.
6.4
Input data validation and sanitization on the server?
Do not rely solely on client-side validation.
6.5
Are endpoints susceptible to SQLi, NoSQLi, or Command Injection?
Check for injections.
7. Functional Security (Withdrawal, Trading)
No.
Check
Note
7.1
Check for double-withdrawals?
Check the transaction processing logic.
7.2
Are there withdrawal limits (daily, weekly)?
And for API keys as well.
7.3
Check for race conditions?
Especially under high load (e.g., quick trades/withdrawals).
7.4
Are transaction errors (insufficient funds, etc.) handled correctly?
There should be no duplication or losses.
7.5
Check for unauthorized order modifications?
Ensure that only the owner can modify/cancel them.
8. Detection and Response
No.
Check
Note
8.1
Is there monitoring for abnormal behavior (unusual logins, outputs)?
Alert system.
8.2
WAF (Web Application Firewall) check?
Protection against known attacks.
8.3
Are pentests and audits conducted regularly?
External and internal.
8.4
Is there an Incident Response Plan?
Is the procedure for action in the event of a hack described?

