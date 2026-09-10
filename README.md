# PYP — Pick Your Photographer (LensMatch)

PYP is an on-demand marketplace connecting customers with verified photographers, videographers, and creators across India.

---

## 🚀 One-Time Setup & Configuration Checklist

### 1. Google Sign-In & Firebase Configuration (Fix for `ApiException: 10`)

`ApiException: 10` is a Google Play Services **Developer Error** caused when the Android signing keystore's SHA-1 fingerprint is not registered in Google Cloud / Firebase Console.

#### Step 1: Confirm Keystore SHA-1 & SHA-256 Fingerprints
For local debug builds, your keystore fingerprints are:
* **SHA-1**: `B3:A3:9F:6E:CD:06:9E:C4:C2:4B:BE:C5:5F:31:93:10:24:48:F3:EB`
* **SHA-256**: `47:65:8B:26:5A:26:5D:5A:DE:22:1B:D5:E8:05:A6:C3:5E:30:7C:2B:D2:A6:AD:E9:45:49:87:AC:D2:3C:B6:37`

*(You can verify anytime using: `keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android`)*

#### Step 2: Add SHA-1 to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/) and select project **`lensmatch-70aee`**.
2. Go to ⚙️ **Project Settings** > **General** tab > scroll down to **Your apps**.
3. Select the Android app with package name `com.pyp.lensmatch`.
4. Click **Add Fingerprint** and paste:
   ```
   B3:A3:9F:6E:CD:06:9E:C4:C2:4B:BE:C5:5F:31:93:10:24:48:F3:EB
   ```
5. Click **Save**.
6. (Optional but recommended) Add the SHA-256 fingerprint as well.

#### Step 3: Download and Replace `google-services.json`
1. On the same page in Firebase Console, click **Download google-services.json**.
2. Replace the file at:
   ```
   android/app/google-services.json
   ```

---

### 2. Supabase Realtime & Database Migration (Fix for `channelError` & `PGRST204`)

To ensure Realtime chat, live bookings, and payment checkout run without errors:

1. Open [Supabase Dashboard](https://supabase.com/dashboard) and navigate to **SQL Editor**.
2. Run the SQL script from [`supabase_patch.sql`](supabase_patch.sql):
   ```sql
   -- 1. Enable Realtime Replication
   DO $$
   BEGIN
       IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
           ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
           ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
           ALTER PUBLICATION supabase_realtime ADD TABLE public.users;
       END IF;
   EXCEPTION
       WHEN duplicate_object THEN NULL;
   END $$;

   -- 2. Add Booking Compatibility Columns
   ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS customer_avatar TEXT;
   ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS customer_name TEXT;
   ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS customer_phone TEXT;
   ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS photographer_name TEXT;
   ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS photographer_avatar TEXT;
   ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS package_title TEXT;
   ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS event_type TEXT;

   -- 3. Reload PostgREST Cache
   NOTIFY pgrst, 'reload schema';
   ```

---

## 🛠️ Testing & Building the App

Run the following commands in the workspace root:

```powershell
# 1. Clean build cache
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Verify code quality (0 errors)
flutter analyze

# 4. Build Debug APK
flutter build apk --debug

# 5. Run on connected Android device
flutter run -d android
```

---

## 📁 Key Architecture & File Structure

- **`lib/services/auth_service.dart`**: Unified authentication with Supabase Auth, Google OAuth ID Token exchange, phone OTP, and deterministic UUID namespace hashing.
- **`lib/services/supabase_service.dart`**: Database operations with schema-safe payloads (`toDatabaseMap()`), resilient stream error handling, and offline fallbacks.
- **`lib/services/conversation_service.dart`**: Realtime messaging CDC stream, chat inbox synchronization, and local push notifications.
- **`lib/models/booking_model.dart`**: Booking entity with dedicated `toDatabaseMap()` ensuring strict PostgREST column adherence.
- **`lib/models/chat_message_model.dart`**: Message entity with UUID formatting and schema normalization.
