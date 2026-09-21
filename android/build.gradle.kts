allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix for isar_flutter_libs and other old libs incompatible with AGP 8+/9+
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            val android = extensions.findByType(com.android.build.api.dsl.LibraryExtension::class.java)
            if (android != null) {
                // Add missing namespace from AndroidManifest.xml
                if (android.namespace == null) {
                    val manifestFile = file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val pkg = groovy.xml.XmlParser().parse(manifestFile).attribute("package") as? String
                        if (pkg != null) android.namespace = pkg
                    }
                }
                // Bump compileSdk so old libs are compatible with new AndroidX
                if (android.compileSdk != null && android.compileSdk!! < 36) {
                    android.compileSdk = 36
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
