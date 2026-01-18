// FICHIER: android/build.gradle.kts
// CORRECTIF UNIVERSEL : ISAR + ANDROID 14 + NAMESPACE + TIMING

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val project = this
    project.buildDir = File(newBuildDir.asFile, project.name)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// --- DÉBUT DU PATCH ---
subprojects {
    val project = this
    // On définit des propriétés globales que certains plugins lisent parfois
    project.extensions.extraProperties.set("compileSdkVersion", 34)
    project.extensions.extraProperties.set("targetSdkVersion", 34)

    // Fonction de correction à appliquer
    fun fixProject(p: Project) {
        val android = p.extensions.findByName("android")
        if (android != null) {
            // 1. FORCER LE SDK 34 (Fix lStar)
            try {
                val setCompileSdkVersion = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdkVersion.invoke(android, 34)
                
                // Petit log pour vérifier que ça marche
                if (p.name.contains("isar")) {
                    println("✅ PATCH APPLIQUÉ SUR : ${p.name} (SDK 34 forcé)")
                }
            } catch (e: Exception) {
                // Erreur silencieuse
            }

            // 2. FORCER LE NAMESPACE (Fix Build)
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    var newNamespace = p.group.toString()
                    if (newNamespace.isEmpty() || newNamespace == "unspecified") {
                        newNamespace = "com.example.${p.name}"
                    }
                    setNamespace.invoke(android, newNamespace)
                }
            } catch (e: Exception) {
                // Erreur silencieuse
            }
        }
    }

    // LOGIQUE ANTI-CRASH : Vérifier l'état du projet avant d'agir
    if (project.state.executed) {
        // Si le projet est déjà chargé (cas Isar souvent), on applique tout de suite
        fixProject(project)
    } else {
        // Sinon, on attend qu'il soit chargé
        project.afterEvaluate {
            fixProject(this)
        }
    }
}
// --- FIN DU PATCH ---