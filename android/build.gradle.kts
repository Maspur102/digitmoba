allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// SKRIP PENYELAMAT REVISI FINAL (Namespace + AAPT lStar SDK 34)
fun fixAndroidExtension(project: Project) {
    project.extensions.findByName("android")?.let { androidExt ->
        // 1. Fix Namespace
        try {
            val namespace = androidExt.javaClass.getMethod("getNamespace").invoke(androidExt)
            if (namespace == null) {
                androidExt.javaClass.getMethod("setNamespace", String::class.java).invoke(androidExt, project.group.toString())
            }
        } catch (e: Exception) {}
        
        // 2. Fix AAPT lStar (Force Compile SDK to 34)
        try {
            androidExt.javaClass.getMethod("setCompileSdk", Int::class.java).invoke(androidExt, 34)
        } catch (e: Exception) {
            try {
                androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.java).invoke(androidExt, 34)
            } catch (e2: Exception) {
                try {
                    androidExt.javaClass.getMethod("compileSdkVersion", Int::class.java).invoke(androidExt, 34)
                } catch (e3: Exception) {}
            }
        }
    }
}

subprojects {
    if (state.executed) {
        fixAndroidExtension(this)
    } else {
        afterEvaluate {
            fixAndroidExtension(this)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}