plugins {
    id("com.android.application")
    // Tambahkan plugin kotlin jika memakai swift/kotlin standar
    id("kotlin-android")
    // Plugin utama untuk build flutter terbaru
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.digitmoba"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // ID Unik Aplikasi
        applicationId = "com.example.digitmoba"
        
        // Versi minimal Android yang didukung
        minSdk = flutter.minSdkVersion
        
        // --- JURUS CHEAT CODE: TARGET SDK 28 ---
        // Menurunkan targetSdk ke 28 agar sistem Android (W^X) 
        // tidak memblokir pengeksekusian file binary Git.
        targetSdk = 28 
        
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            // Konfigurasi bawaan saat kita merilis ke format APK Release
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}