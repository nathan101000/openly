import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore from either key.properties (local) or GitHub Actions env (CI)
val keystore: Map<String, String?> = run {
    val props = Properties()
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        props.load(FileInputStream(file))
        mapOf(
            "keyAlias" to props["keyAlias"] as String,
            "keyPassword" to props["keyPassword"] as String,
            "storeFile" to props["storeFile"]?.toString(),
            "storePassword" to props["storePassword"] as String
        )
    } else {
        mapOf(
            "keyAlias" to System.getenv("KEY_ALIAS"),
            "keyPassword" to System.getenv("KEY_ALIAS_PASSWORD"),
            "storeFile" to System.getenv("KEYSTORE_PATH"),
            "storePassword" to System.getenv("KEYSTORE_PASSWORD")
        )
    }
}

android {
    namespace = "com.natelab.openly"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.natelab.openly"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystore["keyAlias"]
            keyPassword = keystore["keyPassword"]
            storeFile = keystore["storeFile"]?.let { file(it) }
            storePassword = keystore["storePassword"]
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            signingConfig = signingConfigs.getByName("release")

            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
