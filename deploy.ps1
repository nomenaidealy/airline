# =========================
# CONFIGURATION
# =========================

$APP_NAME = "GCA"
$SRC_DIR = "src\main"
$WEB_DIR = "src\main\webapp"
$BUILD_DIR = "build"
$LIB_DIR = "lib"
$TOMCAT_WEBAPPS = "D:\soft\Tomcat\10.1.50\webapps"  
$SERVLET_API_JAR = "$LIB_DIR\servlet-api.jar"

# =========================
# NETTOYAGE + DOSSIERS
# =========================

if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
}

New-Item -ItemType Directory -Path "$BUILD_DIR\WEB-INF\classes" -Force | Out-Null

# =========================
# COMPILATION JAVA
# =========================

Write-Host " Compilation des fichiers Java..."

$javaFiles = Get-ChildItem -Path $SRC_DIR -Recurse -Filter "*.java" |
             Select-Object -ExpandProperty FullName

if ($javaFiles.Count -eq 0) {
    Write-Host " Aucun fichier Java trouvé." -ForegroundColor Red
    exit
}

javac -cp $SERVLET_API_JAR -d "$BUILD_DIR\WEB-INF\classes" $javaFiles

# =========================
# COPIE DES FICHIERS WEB
# =========================

Write-Host " Copie des fichiers web..."

Copy-Item "$WEB_DIR\*" "$BUILD_DIR\" -Recurse -Force

# =========================
# CRÉATION DU WAR
# =========================

Write-Host " Génération du WAR..."

Push-Location $BUILD_DIR
jar -cvf "$APP_NAME.war" *
Pop-Location

# =========================
# DÉPLOIEMENT TOMCAT
# =========================

Copy-Item "$BUILD_DIR\$APP_NAME.war" "$TOMCAT_WEBAPPS\" -Force

Write-Host ""
Write-Host " Déploiement terminé. Redémarrez Tomcat si nécessaire." -ForegroundColor Green
Write-Host ""