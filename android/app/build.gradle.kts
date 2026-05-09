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
        
        // --- PERBAIKAN ERROR DI SINI ---
        // Menggunakan sintaks asli bawaan Kotlin DSL terbaru
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}