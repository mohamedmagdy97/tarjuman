allprojects {
    repositories {
        google()
        mavenCentral()
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
// Play requires 16 KB page-size compatible native libraries (Android 15+).
// Plugin modules build their own CMake targets, so force NDK r28 + flexible page sizes on all of them.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            ndkVersion = "28.2.13676358"
            defaultConfig.externalNativeBuild.cmake.arguments(
                "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON",
            )
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
