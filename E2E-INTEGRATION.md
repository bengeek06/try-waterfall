# 🧪 Tests End-to-End (E2E) - Guide d'intégration CI/CD

## 📋 Vue d'ensemble

Ce document décrit l'intégration des tests end-to-end dans le pipeline CI/CD de Waterfall using the test suite from [e2e-waterfall repository](https://github.com/bengeek06/e2e-waterfall).

## 🏗️ Architecture des tests

### Types de tests intégrés

1. **Tests API** (`api/`)
   - Tests des endpoints d'authentification
   - Tests des services Identity et Guardian  
   - Tests système (health, version, config)
   - Tests de permissions et politiques

2. **Tests UI** (`ui/`)
   - Tests d'initialisation de l'application
   - Tests de login et authentification
   - Navigation et workflows utilisateur

3. **Tests d'intégration**
   - Communication entre services
   - Workflows complets end-to-end

## ⚙️ Intégration dans les workflows

### 1. Build and Test Workflow (`.github/workflows/build-and-test.yml`)

**Scope** : Tests de validation rapides
- Exécuté sur chaque push/PR vers `main`
- Tests API critiques uniquement
- Timeout : 180 secondes
- Échecs max : 3

```yaml
- name: Run E2E Tests
  uses: ./.github/actions/run-e2e-tests
  with:
    test_scope: 'build'
    web_url: 'https://localhost'
    timeout: '180'
```

### 2. Publish Image Workflow (`.github/workflows/publish-image.yml`)

**Scope** : Tests complets de validation
- Exécuté avant publication d'une image Docker
- Suite complète : API + UI
- Timeout : 300 secondes  
- Échecs max : 5

```yaml
- name: Run E2E Tests on Published Image
  uses: ./.github/actions/run-e2e-tests
  with:
    test_scope: 'publish'
    web_url: 'https://localhost'
    timeout: '300'
```

## 🔧 Configuration des tests

### Variables d'environnement

Les tests utilisent les variables suivantes (configurées automatiquement) :

```bash
WEB_URL=https://localhost
COMPANY_NAME=E2ETestCompany
LOGIN=e2e@test.com
PASSWORD=E2ETestPassword123!
LOG_LEVEL=INFO
```

### Scopes de tests

- **`build`** : Tests API essentiels (auth, system health)
- **`publish`** : Tests complets API + UI d'initialisation et login
- **`full`** : Tous les tests (utilisé pour validation manuelle)

## 🚀 Exécution des tests

### Prérequis automatiquement installés

1. **Python 3.13+** avec venv
2. **Chrome/Chromium** pour Selenium  
3. **Dependencies Python** depuis requirements.txt
4. **Configuration SSL** pour tests HTTPS

### Séquence d'exécution

1. **Clone du repo de tests** depuis GitHub
2. **Setup environnement Python** (venv + pip install)
3. **Installation Chrome** pour tests Selenium
4. **Configuration variables** d'environnement de test
5. **Exécution pytest** avec scope approprié
6. **Upload des artefacts** (logs, screenshots si échec)

## 📊 Rapports et débogage

### Artefacts conservés (7 jours)

- **Logs de tests** : Détails d'exécution
- **Screenshots** : Captures d'écran en cas d'échec Selenium
- **Résultats pytest** : Rapports détaillés

### Accès aux artefacts

1. Aller dans GitHub Actions → Workflow run
2. Section "Artifacts" en bas de page
3. Télécharger `e2e-test-results-{scope}`

## 🔍 Tests spécifiques exécutés

### Build Scope
```bash
pytest api/auth/ api/*/test_*system.py -v --tb=short --maxfail=3
```

### Publish Scope  
```bash
pytest api/ ui/test_app_init.py ui/login/test_login.py -v --tb=short --maxfail=5
```

## 🛠️ Maintenance et dépannage

### Tests qui échouent

1. **Vérifier les logs** dans les artefacts
2. **Augmenter les timeouts** si nécessaire dans action.yml
3. **Vérifier la configuration** de l'application testée

### Optimisation des performances

- Tests API d'abord (plus rapides)
- Selenium en mode headless
- Timeouts configurables par scope
- Nettoyage automatique des ressources

### Mise à jour des tests

Les tests sont automatiquement récupérés depuis le repo `e2e-waterfall`. Pour modifier les tests :

1. Modifier les tests dans le repo `e2e-waterfall`
2. Les workflows utiliseront automatiquement la version `main`

## 📝 Exemple de logs d'exécution

```
🧪 Cloning E2E test repository...
✅ E2E repository cloned
🐍 Setting up Python environment...
✅ Python environment ready  
🌐 Installing Chrome for Selenium tests...
✅ Chrome installed
⚙️ Configuring test environment...
✅ Environment configured
🧪 Running E2E tests (scope: build)...
Running build validation tests...
✅ E2E tests completed successfully!
```

## 🎯 Critères de succès

- ✅ Tous les tests du scope passent
- ✅ Timeout non dépassé
- ✅ Nombre d'échecs < seuil configuré
- ✅ Application répond correctement aux health checks
- ✅ Workflows UI complets fonctionnels

Cette intégration garantit que chaque image Docker publiée a été validée par une suite complète de tests end-to-end couvrant tous les aspects critiques de l'application Waterfall.