# DriveIn for iPhone

*Your car is the cinema.*

DriveIn is a home screen for streaming apps on iPhone:

- **Every video service plays inside DriveIn.** YouTube, Netflix, Prime Video, Disney+, Max, Apple TV, Twitch and Plex open in DriveIn's own player, using each service's website. Sign in once and DriveIn remembers you.
- **Desktop website switch** in the ⋯ menu. Some services only play on their desktop site, so Netflix, Prime Video, Disney+, Max and Apple TV start in desktop mode. The same menu can open the real app instead.
- **Spotify, YouTube Music, Apple Music and Podcasts** in a Listen section, which never locks.
- **Parked lock.** DriveIn reads your speed with GPS and motion. Video only shows when the car has been still for about 8 seconds. When you drive off, the picture is covered and the sound carries on, or playback pauses if you turn that on in Settings.
- **Ready for AirPlay video in the car.** iOS 26 allows video on the car screen through AirPlay while parked, in cars whose maker turns it on. DriveIn's player has AirPlay enabled.

There are a few things it can't do. Apple doesn't let apps put video on the CarPlay screen except through that iOS 26 parked feature, so DriveIn runs on the iPhone screen. Paid services decide whether their website plays on an iPhone. If one refuses inside DriveIn, try the desktop switch, or use "Open the app instead".

---

## Get it on your iPhone from a Windows PC

You need a Mac to build iPhone apps, so GitHub builds DriveIn for you on one of its Macs for free. Then Sideloadly puts it on your iPhone.

### 1. Build the app on GitHub (about 10 minutes the first time)

1. Create a free account at github.com.
2. Click **New repository**. Name it `drivein`, choose **Public** (unlimited free builds) or **Private** (about 200 free Mac build minutes a month), and click **Create repository**.
3. Click **uploading an existing file**. Unzip `DriveIn-iOS.zip` on your PC and drag **everything inside the folder** onto the page, including the `.github` folder. Click **Commit changes**.
   - If Windows hides the `.github` folder, open File Explorer, then View, Show, and tick **Hidden items**.
4. Open the **Actions** tab. The **Build DriveIn** run starts on its own. Wait for the green tick (about 5 minutes).
5. Click the finished run. Under **Artifacts**, download **DriveIn-ipa**. Unzip it to get `DriveIn.ipa`.

### 2. Install on your iPhone with Sideloadly

1. Install **iTunes** (the version from apple.com, not the Microsoft Store one) and **Sideloadly** (sideloadly.io) on your PC.
2. Plug in your iPhone and tap **Trust** on the phone.
3. In Sideloadly, drag in `DriveIn.ipa`, type your Apple ID email, and click **Start**. Sign in when it asks.
4. On the iPhone:
   - **Settings → Privacy & Security → Developer Mode → On** (the phone restarts).
   - **Settings → General → VPN & Device Management →** tap your Apple ID → **Trust**.
5. Open DriveIn and tap **Allow** for location and motion.

With a free Apple ID, the app stops opening after **7 days**. Run Sideloadly again to refresh it; you can turn on its auto-refresh option. A paid Apple Developer account ($99 a year) makes it last a year and is needed for the App Store later.

### 3. Making changes

Edit any file on GitHub (click the file, then the pencil icon) and commit. A new build starts automatically.

---

## Project layout

| Path | What it is |
|---|---|
| `project.yml` | Project settings: app name, bundle id, permissions. XcodeGen turns it into an Xcode project. |
| `DriveIn/Models/StreamingApp.swift` | The list of services: names, colours, links, App Store ids. Add or remove services here. |
| `DriveIn/Services/DriveMonitor.swift` | Parked/driving detection (10 km/h counts as moving; parked after 8 s below 4 km/h). |
| `DriveIn/Services/AppLauncher.swift` | Opens other apps, or reports that they're missing. |
| `DriveIn/Views/` | Screens: Home, YouTube player with the driving lock, Settings, tiles. |
| `DriveIn/Assets.xcassets` | App icon and colours. |
| `.github/workflows/build-ipa.yml` | Builds the `.ipa` on GitHub's Macs. |

To add a service, also add its URL scheme to `LSApplicationQueriesSchemes` in `project.yml`.

## Before the App Store

- Apple will reject an app that wraps other companies' websites like this. That's fine for sideloading, but the App Store version would need the official YouTube player and links out to the other apps.
- Don't use service logos without permission. Plain names, as now, are fine.
- Keep the parked lock. It's the reason the app can be sold openly.
