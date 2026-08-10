# ⚡ COMMANDES RAPIDES - BotecoPro

## � WSL Environment Setup (Recommended)

```bash
# If using WSL on Windows, run Flutter commands from WSL
wsl bash -lc "cd /mnt/c/Users/$(whoami)/Desktop/Monynha\ Sotwares/Codebase/BotecoPro && flutter --version"

# Setup Flutter in WSL
wsl bash -lc "export PATH=\$PATH:\$HOME/flutter/bin && flutter pub get"

# Run web app in WSL
wsl bash -lc "cd /mnt/c/Users/$(whoami)/Desktop/Monynha\ Sotwares/Codebase/BotecoPro && flutter run -d web"
```

---

## 🏗️ BUILD

```bash
# Build web (debug rapide)
flutter build web

# Build web (production optimisé)
flutter build web --release

# Output: build/web/
ls -lh build/web/

# Taille typique: ~3.8 MB
```

---

## 🧪 TEST LOCAL

```bash
# Servir web localement
cd build/web
python3 -m http.server 8080

# Ouvrir http://localhost:8080
# Tester toutes fonctionnalités
# Vérifier F12 console pour erreurs
```

---

## 🌐 DÉPLOIEMENT FIREBASE

```bash
# Setup une fois
npm install -g firebase-tools
firebase login
firebase init hosting

# Configuration:
# Public directory: build/web
# Single-page app: Yes
# Overwrite index.html: No

# Redéployer après modifs
firebase deploy

# URL en ligne: https://botecoproXXXX.web.app
```

---

## 📊 ANALYSE CODE

```bash
# Vérifier erreurs
flutter analyze

# Formater code
dart format lib/

# Diagnostiquer problèmes
flutter doctor -v
```

---

## 🧹 NETTOYAGE

```bash
# Supprimer build cache
flutter clean

# Réinstaller dépendances
flutter pub get

# Full rebuild
flutter clean && flutter pub get && flutter build web --release
```

---

## 📱 PLATEFORME ALTERNATIVE

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

---

## 🔍 DEBUG

```bash
# Mode verbose (debug détaillé)
flutter run -d web -v

# Voir logs complètes
flutter logs

# Ouvrir DevTools
dart devtools
```

---

## 💾 DONNÉES

```bash
# Accéder localStorage en console navigateur
# F12 → Console

// Voir tous les produits
localStorage.getItem("products")

// Voir tous les commandes
localStorage.getItem("orders")

// Effacer données (danger!)
localStorage.clear()
```

---

## 📈 PERFORMANCE

```bash
# Vérifier taille bundle
flutter build web --release
du -sh build/web/

# Analyser assets
flutter build web --release --analyze-size

# Voir dependances
flutter pub deps --style=compact
```

---

## 🔄 WORKFLOW DÉVELOPPEMENT

```bash
# 1. Modifier code
nano lib/presentation/pages/home_page.dart

# 2. Rebuild local
flutter run -d web

# 3. Test dans navigateur
# F12 pour debug

# 4. Redéployer (après tests)
flutter build web --release
firebase deploy
```

---

## 🆘 TROUBLESHOOTING

```bash
# Erreur: "flutter command not found"
export PATH="/path/to/flutter/bin:$PATH"

# Erreur: "SDK mismatch"
flutter upgrade

# Erreur: "Web platform not available"
flutter create --platforms=web .

# Erreur: "build/web/ doesn't exist"
flutter build web --release

# Erreur: Firebase deploy fails
firebase login
firebase use --add
firebase deploy --force
```

---

## 📞 RESSOURCES

```bash
# Documentation Flutter Web
open https://flutter.dev/docs/get-started/web

# Firebase Hosting Docs
open https://firebase.google.com/docs/hosting

# Dart Docs
open https://dart.dev/guides

# Flutter Community
open https://flutter.dev/community
```

---

## 🎯 CHECKLIST PRE-DEPLOY

```bash
# ✅ Code linting
flutter analyze  # Doit être clean

# ✅ Build web
flutter build web --release  # Doit réussir

# ✅ Test local
cd build/web && python3 -m http.server 8080
# Tester 5 min...

# ✅ Firebase ready
firebase projects:list  # Voir projets

# ✅ Deploy
firebase deploy

# ✅ Vérifier URL
open https://botecoproXXXX.web.app
```

---

## 📊 GIT

```bash
# Status
git status

# Add changes
git add .

# Commit
git commit -m "Update web deployment"

# Push
git push origin master

# View history
git log --oneline

# Revert derniers changements
git reset --hard HEAD
```

---

## 🎉 COMMANDES FAVORIS

```bash
# "Je veux juste lancer l'app maintenant"
flutter run -d web

# "Je veux déployer en prod"
flutter build web --release && firebase deploy

# "Quelque chose ne marche pas"
flutter clean && flutter pub get && flutter analyze

# "Je veux voir ma perf"
flutter build web --analyze-size

# "Montrer le diff"
git diff lib/

# "Version finale prête pour production"
flutter build web --release && firebase deploy --only hosting
```

---

## 💡 ASTUCES

```bash
# Alias pour commands fréquentes
alias fweb="flutter build web --release"
alias fdeploy="firebase deploy"
alias fanalyz="flutter analyze && dart format lib/"
alias fclean="flutter clean && flutter pub get"

# Usage:
fclean && fanalyz && fweb && fdeploy
```

---

**Besoin d'aide?** Consultez les fichiers de doc:
- [README.md](./README.md) - Vue générale
- [QUICK_SUMMARY.md](./QUICK_SUMMARY.md) - Résumé complet
- [FIREBASE_DEPLOYMENT_GUIDE.md](./FIREBASE_DEPLOYMENT_GUIDE.md) - Firebase pas-à-pas
- [WEB_ARCHITECTURE.md](./WEB_ARCHITECTURE.md) - Architecture technique

**Prêt? Let's GO! 🚀**
