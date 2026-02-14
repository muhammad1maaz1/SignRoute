plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.signroute"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    sourceSets {
        getByName("main") {
            assets.srcDirs("src/main/assets")
        }
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.signroute"
        minSdk = 26
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.alphacephei:vosk-android:0.3.47")

    // MediaPipe: Iska apna TFLite nikal rahe hain taake conflict na ho
    implementation("com.google.mediapipe:tasks-vision:0.10.14") {
        exclude(group = "org.tensorflow", module = "tensorflow-lite")
        exclude(group = "org.tensorflow", module = "tensorflow-lite-support")
        exclude(group = "org.tensorflow", module = "tensorflow-lite-api")
    }

    // === TENSORFLOW LITE 2.15.0 (Same as your Model) ===
    implementation("org.tensorflow:tensorflow-lite:2.15.0")
    implementation("org.tensorflow:tensorflow-lite-gpu:2.15.0")
    implementation("org.tensorflow:tensorflow-lite-select-tf-ops:2.15.0")
    implementation("org.tensorflow:tensorflow-lite-support:0.4.4")
}

// === FORCE VERSION 2.15.0 ===
// Ye ensure karega ke MediaPipe bhi zabardasti 2.15.0 hi use kare
configurations.all {
    resolutionStrategy {
        force("org.tensorflow:tensorflow-lite:2.15.0")
        force("org.tensorflow:tensorflow-lite-api:2.15.0")
        force("org.tensorflow:tensorflow-lite-gpu:2.15.0")
        force("org.tensorflow:tensorflow-lite-select-tf-ops:2.15.0")
    }
}