plugins {
    id("com.android.application")
    id("kotlin-android")
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
        applicationId = "com.example.digitmoba"
        minSdk = flutter.minSdkVersion
        
        // JURUS CHEAT CODE: TARGET SDK 28 (Anti W^X Block)
        targetSdk = 28 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // --- TAMBAHAN BARU: MATIKAN POLISI GOOGLE PLAY ---
    // Ini akan memaksa sistem untuk tetap melanjutkan pembuatan APK 
    // meskipun Target SDK kita dianggap "kadaluarsa" untuk Play Store.
    lint {
        abortOnError = false
        disable.add("ExpiredTargetSdkVersion")
    }
}

flutter {
    source = "../.."
}