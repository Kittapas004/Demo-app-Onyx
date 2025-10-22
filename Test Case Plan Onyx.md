**Test Plan: Detailed Cases**  
**1\. Scope**  
	Functional, UI/UX, validation, navigation, and payment flows for IOS/Android. Focused on authentication, registration, artwork auction, payment, and notification.  
**Project: Onyx – Auction Platform for Art (Mobile)**  
	Purpose: Define essential manual test coverage for major user journeys and key edge cases of the Onyx mobile app.  
Audience: QA engineers, developers, and product owners.  
Date: \[October 19, 2025\]  
**2\. Test Strategy**  
	**Approach:** Risk‑based. Prioritize login, KYC, bidding, and payments.  
	**Levels:** Component, integration, and system.  
	**Types:** Functional, UI/UX, Validation, and Regression.  
**3\. Test Environments & Data**

* **ENV:** Staging backend with seed data.  
* **Accounts:** buyer, artist, and admin roles.  
* **Cards (sandbox):** Visa and MasterCard test tokens.  
* **Sample Art:** “Stupid Monkey”, “Color of Life”.

## **4\. Entry/Exit Criteria**

**Entry:** Environment ready and data seeded.  
**Exit:** All P0/P1 test cases pass with no critical defects.

**5\. Detailed Test Cases**  
	5.1 Authentication

| ID | Type | Steps | Expected Results |
| :---- | :---- | :---- | :---- |
| AU‑001 | (Happy) Email login | Enter valid email/password → Login. | Lands on Home screen. |
| AU‑002 | (Sad) Wrong password | Enter wrong password. | Error “Invalid credentials”. |
| AU‑003 | (Happy) Google OAuth | Tap Gmail icon → login. | User logged in successfully. |
| AU‑004 | (Edge) Empty fields | Tap Login with no input. | Validation errors shown. |
| AU‑005 | Logout | Tap Logout. | Returns to login page. |

5.2 Registration & KYC

| ID | Type | Steps | Expected Results |
| :---- | :---- | :---- | :---- |
| RG‑001 | (Happy) Register | Fill all fields → Register. | Account created successfully. |
| RG‑002 | Duplicate email | Use existing email. | Error “Email already registered”. |
| KYC-001 | (Happy) Upload ID | Go to Profile → Verify ID → Upload photo. | Status becomes “Pending Review”. |
| KYC-002 | (Sad) Rejected ID | Submit blurry image. | “Verification failed” message displayed. |

5.3 Artwork Auction & Bidding

| ID | Type | Steps | Expected Results |
| :---- | :---- | :---- | :---- |
| BD‑001 | (Happy) View artwork | Open listing. | Artwork info displays correctly. |
| BD‑002 | (Happy) Place a quick bid | Tap preset amount → Confirm. | Bid accepted; price updates. |
| BD‑003 | (Sad) Below min bid | Enter too‑low custom bid. | Error “Minimum increment required”. |
| BD‑004 | (Sad) Not verified | Unverified user taps Bid. | Prompt to verify ID. |
| BD‑005 | (Edge) Auction ended | Open-ended item. | Controls disabled, shows “Ended”. |

5.4 Add Your Art (Seller Flow)

| ID | Type | Steps | Expected Results |
| :---- | :---- | :---- | :---- |
| AA‑001 | (Happy) Submit listing | Enter all fields, upload image → Submit. | Art added to listings. |
| AA‑002 | (Sad) Missing image | Try submitting without upload. | Error “Image required”. |
| AA‑003 | (Sad) Invalid price range | Min \> Max. | Validation error displayed. |

5.5 Payments

| ID | Type | Steps | Expected Results |
| :---- | :---- | :---- | :---- |
| PM‑001 | (Happy) Add card | Enter valid info → Save. | Card saved successfully. |
| PM‑002 | (Sad) Invalid number | Enter wrong digits. | Error “Invalid card number”. |
| PM‑003 | (Happy) Pay invoice | Confirm & Pay. | Payment succeeds; receipt shown. |
| PM‑004 | (Sad) Gateway decline | Use decline token. | Error “Payment declined”. |

5.6 Notifications

| ID | Type | Steps | Expected Results |
| :---- | :---- | :---- | :---- |
| NT‑001 | (Happy) View list | Tap bell icon. | Notifications displayed. |
| NT‑002 | (Happy) Outbid alert | Competing bid placed. | Push received → opens artwork. |
| NT‑003 | (Sad) Permission denied | Deny notifications. | Prompt to enable in settings. |

5.7 Help & Chat

| ID | Type | Steps | Expected Results |
| :---- | :---- | :---- | :---- |
| HP‑001 | (Happy) Send message | Open Help → Send text. | Message delivered; reply visible. |
| HP‑002 | (Edge) Offline send | Send while offline. | Message queued; sends after reconnect. |

## **6\. Regression Pack**

AU‑001, AU‑003, RG‑001, KYC‑001, BD‑002, PM‑003, NT‑002, HP‑001.

## **7\. Risks**

* Live bidding race conditions (bid collisions). Payment failures or escrow mismatches. KYC capture failures. Push delivery variability. Image upload latency.

## **8\. Sign‑off** **QA Lead:** Thammarat Siangjong | **Chief Executive Officer:** Panadda Paenjak

## 