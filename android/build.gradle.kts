allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// JDK21環境で一部プラグイン（例: receive_sharing_intent）が Java(11) と Kotlin(21) の
// JVMターゲット不一致を起こすため、全サブプロジェクトを 17 に統一する。
// ※ 下の evaluationDependsOn(":app") より前に afterEvaluate を仕込むのが重要。
//   後に置くと一部モジュールが評価済みになり「already evaluated / finalized」で失敗する。
subprojects {
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
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
