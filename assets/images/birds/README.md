# Bird Images Directory

This directory contains images of birds for the Avicast mobile app.

## 📁 File Naming Convention

Use the following format for bird image files:
- `common_name.jpg` (e.g., `spoon_billed_sandpiper.jpg`)
- `common_name.png` (e.g., `chinese_egret.png`)

## 🖼️ Recommended Image Specifications

- **Format**: JPG or PNG
- **Size**: 300x300 pixels minimum (square aspect ratio recommended)
- **Quality**: High quality, clear images
- **Background**: Clean, natural backgrounds preferred
- **File Size**: Keep under 500KB for optimal app performance

## 📋 Birds Currently Supported

The following **15 birds** have image paths configured in the app:

1. **Spoon-billed Sandpiper** - `spoon_billed_sandpiper.jpg`
2. **Chinese Egret** - `chinese_egret.jpg`
3. **Black-faced Spoonbill** - `black_faced_spoonbill.jpg`
4. **Baer's Pochard** - `baers_pochard.jpg`
5. **Far Eastern Curlew** - `far_eastern_curlew.jpg`
6. **Whiskered Tern** - `whiskered_tern.jpg`
7. **Barn Swallow** - `barn_swallow.jpg`
8. **Peregrine Falcon** - `peregrine_falcon.jpg`
9. **Great Knot** - `great_knot.jpg`
10. **Nordmann's Greenshank** - `nordmanns_greenshank.jpg`
11. **Common Redshank** - `common_redshank.jpg`
12. **Saunders's Gull** - `saunderss_gull.jpg`
13. **Oriental Stork** - `oriental_stork.jpg`
14. **Red-crowned Crane** - `red_crowned_crane.jpg`
15. **Chinese Crested Tern** - `chinese_crested_tern.jpg`

## 🔄 Adding New Bird Images

1. **Place the image file** in this directory
2. **Update the bird database** in `lib/features/bird_counting/data/services/offline_bird_api_service.dart`
3. **Add the image path** to the bird's data entry
4. **Test the image** in the app

## 📱 How Images Are Used

- **Bird Counter Page**: Shows bird images when selecting species
- **Site Birds Page**: Displays bird images in the species list
- **Bird Details**: Shows larger images in detailed views
- **Offline Support**: All images are bundled with the app for offline use

## ⚠️ Important Notes

- **Copyright**: Ensure you have rights to use the images
- **Attribution**: Consider adding photographer credits if required
- **Consistency**: Try to maintain consistent image quality and style
- **Performance**: Optimize images to avoid app bloat

## 🆘 Troubleshooting

If images don't appear:
1. Check the file path in the bird database
2. Ensure the image file exists in this directory
3. Verify the image format is supported (JPG/PNG)
4. Check that the file name matches exactly (case-sensitive)
5. Run `flutter clean` and `flutter pub get` if needed 