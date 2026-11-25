# NutriTrack — Flutter starter app

A single Flutter codebase intended for Android and responsive Web.

## Included
- Food search catalogue with sample fruits, vegetables, drinks, grains, protein foods, seeds and nuts.
- Add consumed foods to a daily log.
- Daily count by food category, estimated calories and protein.
- Editable meal timings.
- Local persistence using `shared_preferences`.

## Build the APK using GitHub from an Android phone
1. Sign in to GitHub in your mobile browser.
2. Create a new **public or private repository** named `nutri-track`.
3. Upload the contents of this ZIP into the repository (not the ZIP file itself). Make sure `.github/workflows/build-apk.yml` is included.
4. Open the repository's **Actions** tab.
5. Select **Build NutriTrack APK**, then tap **Run workflow** (or wait for the first push build to finish).
6. Open the completed workflow run and download the **NutriTrack-Android-APK** artifact.
7. Extract the downloaded artifact ZIP. It contains `app-release.apk`. Tap it to install; Android may ask you to allow installs from that browser/files app.

## Important
- This is a starter app, not a finished production nutrition product.
- The food list is a sample catalogue, not every food. Nutrient values are estimates and vary by portion and preparation.
- Meal log and timing data are stored locally on the device/browser. Cloud sync, user accounts, reminders, and a verified comprehensive food database are not included.
- Do not use calorie/protein estimates as medical advice.
- 
