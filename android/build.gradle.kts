buildscript {
    repositories {
        google()
        mavenCentral()
        // Nightly / snapshot builds ke liye
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots") }
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Nightly / snapshot builds ke liye
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots") }
    }
}

// Common build directory set kar rahe hain
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

// Har subproject ka build folder alag set hoga
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// App project pe depend karwana
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
