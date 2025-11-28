# 🤖 Analyseur d'Articles pour Levées de Fonds

Application complète d'extraction d'informations depuis des articles de presse sur les levées de fonds, utilisant un LLM pour structurer les données et WordPress comme source et destination.

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Installation](#️-installation)
- [Configuration](#️-configuration)
- [Utilisation](#-utilisation)
- [Évolutions futures](#-évolutions-futures)
- [Structure du projet](#-structure-du-projet)

---

## ✨ Fonctionnalités

### 🔐 Gestion Multi-utilisateurs
- Authentification sécurisée avec bcrypt
- Historique personnel d'extractions
- Sélecteur de prompts prédéfinis (e-santé, fintech, retail, général)

### 📝 Extraction LLM
- **Analyse manuelle** : Collez un article et extrait les données structurées
- **Import WordPress** : Connexion directe à votre WordPress multisite
- **Traitement par lots** : CLI pour traiter plusieurs fichiers
- **Auto-correction JSON** : Le LLM corrige automatiquement ses erreurs de format
- **Détection de doublons** : Hash SHA256 pour éviter les duplicatas
- **Traçabilité obligatoire** : URL source requise pour tous les articles

### 🤖 Configuration LLM

**Support multi-LLM** :
- ✅ **OpenAI API** (gpt-4o-mini, gpt-4, etc.) - Recommandé
- ✅ **LM Studio** (local) - En commentaire, disponible comme fallback

**Prompts prédéfinis** :
- 🏥 **Levées de fonds - E-santé** (par défaut)
- 💰 **Levées de fonds - Fintech**
- 🛒 **Levées de fonds - Retail**
- 📊 **Analyse générale**

### 🌐 Intégration WordPress

#### Import depuis WordPress
- ✅ Support WordPress Multisite (sous-domaines ET sous-répertoires)
- ✅ Pré-remplissage automatique du domaine (mind.eu.com)
- ✅ Sélection manuelle des articles avec aperçu
- ✅ Filtres avancés :
  - Recherche par mot-clé
  - Filtrage par date (7 périodes + personnalisé)
  - Filtrage par catégories
  - Pagination
- ✅ Import par lot avec barre de progression
- ✅ Capture automatique de l'URL source
- ✅ Aucune authentification requise pour articles publics

#### Export vers Google Sheets
- ✅ Sélection des extractions à exporter (multiselect + tout sélectionner)
- ✅ Configuration de la feuille de destination (URL + nom d'onglet)
- ✅ Modes d'export : Ajouter ou Remplacer
- ✅ Prévisualisation avant export
- ✅ Export structuré avec toutes les colonnes :
  - ID extraction, Date d'extraction
  - Nom startup, Type, Montant
  - Date de levée (Jour/Mois/Année séparés)
  - Tour de financement
  - Investisseurs (liste complète en une colonne)
  - Lien source (URL)
- ✅ Rapport de succès détaillé (nombre d'extractions, colonnes, mode)
- ✅ Authentification par Service Account (credentials.json)

#### Export vers WordPress (🚧 En développement)
- Réinjection des données extraites vers WordPress
- Choix du site de destination
- Formats configurables (articles, custom fields, etc.)
- Rapport de succès détaillé

### 📊 Gestion des données
- Base PostgreSQL avec JSONB pour flexibilité
- Historique complet avec timestamps
- Export JSON des extractions
- **Export Google Sheets** : Export direct vers vos feuilles Google
- Interface de consultation et filtrage
- **Nouveau format JSON** :
  ```json
  {
    "Nom_start-up": "MedTech France",
    "Type": "E-santé",
    "Montant": "5M€",
    "Date_levée": "15/01/2025",
    "Tour": "Série A",
    "Investisseurs": ["VC1", "VC2", "Business Angel"],
    "Lien": "https://source-article.com"
  }
  ```

---

## 🏗️ Architecture

### Stack Technologique

**Frontend**
- **Streamlit** (1.51.0) - Interface web interactive et moderne
- Navigation latérale : Dashboard, Historique
- Cartes interactives : Analyse manuelle | Import WordPress | Export Google Sheets | Export WordPress
- Design moderne avec boutons violets et cartes blanches

**Backend**
- **Python** 3.13
- **PostgreSQL** - Base de données relationnelle
- **OpenAI API** - LLM cloud (gpt-4o-mini par défaut)
- **LM Studio** (optionnel) - LLM local en fallback

**Librairies principales**
- `openai` - API OpenAI officielle
- `requests` - Connexion WordPress REST API
- `psycopg2-binary` - Driver PostgreSQL
- `bcrypt` - Hachage sécurisé des mots de passe
- `pandas` - Manipulation et affichage des données
- `gspread` - API Google Sheets
- `oauth2client` - Authentification Google Service Account

### Flux de données

```
┌─────────────────────────────────────────┐
│  Sources d'entrée                       │
│  ├─ Saisie manuelle (textarea + URL)    │
│  ├─ Import WordPress REST API           │
│  └─ Fichiers batch (.txt)               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Sélection du Prompt                    │
│  ├─ Levées de fonds - E-santé (défaut)  │
│  ├─ Levées de fonds - Fintech           │
│  ├─ Levées de fonds - Retail            │
│  └─ Analyse générale                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Extraction LLM (OpenAI/LM Studio)      │
│  ├─ Prompt système sélectionné          │
│  ├─ Température : 0.1                   │
│  ├─ Max tokens : 2000                   │
│  └─ Auto-correction JSON (2 retries)    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Base PostgreSQL                        │
│  ├─ users (auth + selected_prompt_id)   │
│  └─ extractions (JSONB + hash unique)   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Sorties                                │
│  ├─ Historique web (consultation)       │
│  ├─ Export JSON                         │
│  ├─ Export Google Sheets (✅)           │
│  └─ Export WordPress (🚧 à venir)       │
└─────────────────────────────────────────┘
```

---

## ⚙️ Installation

### Prérequis

- Python 3.13+
- PostgreSQL 12+
- Clé API OpenAI (ou LM Studio pour usage local)

### Étape 1 : Clone et environnement

```bash
git clone <votre-repo>
cd sprint_Ai_final

# Créer l'environnement virtuel
python3 -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
```

### Étape 2 : Installer les dépendances

```bash
pip install -r requirements.txt
```

### Étape 3 : Configurer le LLM

#### Option 1 : OpenAI API (Recommandé)

1. **Obtenir une clé API** :
   - Aller sur [platform.openai.com](https://platform.openai.com/)
   - Créer une clé API

2. **Configurer le fichier `.env`** :
   ```bash
   cp .env.example .env
   ```

3. **Éditer `.env`** :
   ```bash
   # === Option 1: OpenAI (ACTIVÉ) ===
   USE_OPENAI=true
   OPENAI_API_KEY=sk-proj-votre_clé_ici
   OPENAI_MODEL=gpt-4o-mini

   # === Option 2: LM Studio (DÉSACTIVÉ - En commentaire) ===
   # USE_OPENAI=false
   # LLM_API_URL=http://localhost:1234/v1/chat/completions
   # LLM_MODEL_NAME=local-model
   ```

#### Option 2 : LM Studio (Local)

1. Télécharger [LM Studio](https://lmstudio.ai/)
2. Charger un modèle (ex: Llama, Mistral)
3. Démarrer le serveur local (port 1234 par défaut)
4. Modifier `.env` :
   ```bash
   # === Option 1: OpenAI (DÉSACTIVÉ) ===
   # USE_OPENAI=true
   # OPENAI_API_KEY=sk-proj-...
   # OPENAI_MODEL=gpt-4o-mini

   # === Option 2: LM Studio (ACTIVÉ) ===
   USE_OPENAI=false
   LLM_API_URL=http://localhost:1234/v1/chat/completions
   LLM_MODEL_NAME=votre-modele-local
   ```

### Étape 4 : Configurer Google Sheets (Optionnel)

Pour utiliser l'export Google Sheets :

1. **Créer un Service Account Google** :
   - Aller sur [Google Cloud Console](https://console.cloud.google.com/)
   - Créer un projet
   - Activer l'API Google Sheets
   - Créer un Service Account
   - Télécharger le fichier JSON des credentials

2. **Placer le fichier credentials** :
   ```bash
   # Renommer et placer à la racine du projet
   mv ~/Downloads/votre-projet-xxxxx.json credentials.json
   ```

3. **Partager votre Google Sheet** :
   - Ouvrez votre feuille Google Sheets
   - Cliquez sur "Partager"
   - Ajoutez l'email du service account (trouvé dans credentials.json)
   - Donnez les droits "Éditeur"

### Étape 5 : Configurer PostgreSQL

1. **Installer PostgreSQL**
   ```bash
   # macOS
   brew install postgresql
   brew services start postgresql
   
   # Ubuntu/Debian
   sudo apt install postgresql postgresql-contrib
   sudo systemctl start postgresql
   ```

2. **Créer la base de données**
   ```bash
   createdb sprint_ai_db
   ```

3. **Créer le fichier de configuration**
   ```bash
   mkdir -p .streamlit
   ```

4. **Éditer `.streamlit/secrets.toml`**
   ```toml
   [postgres]
   host = "localhost"
   port = 5432
   dbname = "sprint_ai_db"
   user = "votre_utilisateur"
   password = "votre_mot_de_passe"
   ```

---

## 🚀 Utilisation

### Interface Web (Recommandée)

```bash
streamlit run app.py
```

Ouvrez http://localhost:8501

#### 1️⃣ Créer un compte
- Cliquez sur "Créer un compte" dans la barre latérale
- Choisissez un nom d'utilisateur et mot de passe

#### 2️⃣ Sélectionner le type d'analyse
- Barre latérale > **"📝 Modèle d'extraction"**
- Choisissez parmi :
  - 🏥 **Levées de fonds - E-santé** (par défaut)
  - 💰 **Levées de fonds - Fintech**
  - 🛒 **Levées de fonds - Retail**
  - 📊 **Analyse générale**
- Le prompt système s'adapte automatiquement

#### 3️⃣ Analyser un article manuellement
- Onglet **"Analyse d'Article"**
- **Renseigner l'URL source** (obligatoire pour traçabilité)
- Collez le texte de l'article
- Cliquez sur **"Lancer l'analyse"**
- Les données structurées s'affichent et sont sauvegardées

#### 4️⃣ Importer depuis WordPress
- Onglet **"Import WordPress"**
- **Configuration** (pré-remplie avec mind.eu.com) :
  - Type : Sous-répertoires
  - Domaine : `mind.eu.com`
  - Sites : `health`, `media`, `fintech`, etc. (un par ligne)
- **Tester la connexion**
- **Filtres** :
  - Période : Dernier mois
  - Catégories : Levées de fonds
  - Recherche : "startup"
- **Charger les articles**
- **Sélectionner** les articles souhaités (cases à cocher)
- **Lancer l'extraction** : Le LLM traite chaque article
- L'URL WordPress est automatiquement capturée

#### 5️⃣ Exporter vers Google Sheets
- Cliquez sur la carte **"📊 Export Google Sheets"**
- **Sélectionner les extractions** :
  - Cochez individuellement les extractions désirées
  - Ou utilisez "Tout sélectionner"
- **Configuration Google Sheets** :
  - Collez l'URL de votre feuille Google Sheets
  - Nommez l'onglet (ex: "Extractions")
  - Choisissez le mode : Ajouter ou Remplacer
- **Prévisualiser** pour vérifier les données
- **Exporter** : Les données sont envoyées vers Google Sheets
- **Rapport détaillé** : Nombre d'extractions, colonnes, lien direct

#### 6️⃣ Consulter l'historique
- Sidebar > **"📚 Historique"**
- Visualisez toutes vos extractions avec :
  - Nom de la startup
  - Type et montant
  - Date de levée (jour/mois/année)
  - Tour de financement
  - Liste des investisseurs
  - Lien source
- Téléchargez au format JSON individuel ou global CSV

#### 7️⃣ Dashboard
- Sidebar > **"📊 Dashboard"**
- Statistiques : Total analyses, Dernière analyse, Statut
- Graphique d'activité des 30 derniers jours

### Ligne de commande (Batch)

Pour traiter plusieurs fichiers automatiquement :

#### Option 1 : Fichiers TXT (dossier)

```bash
# Placer les fichiers .txt dans le dossier a_traiter/
cp article*.txt a_traiter/

# Lancer l'extraction
python3 run_extraction.py --user votre_username

# Les fichiers traités sont déplacés dans traites/
```

#### Option 2 : Fichier CSV

Créez un fichier CSV avec une colonne contenant les articles. La colonne peut s'appeler :
- `content`
- `article`
- `text`
- `texte`
- `contenu`

**Exemple de CSV** (`articles.csv`) :

```csv
content
"La startup TechCorp annonce une levée de fonds de 5M€..."
"HealthTech lève 10M€ pour révolutionner la télémédecine..."
"FinanceBot annonce un tour de table de 3M€..."
```

**Lancer l'extraction** :

```bash
python3 run_extraction.py --user votre_username --csv articles.csv
```

**Avantages du CSV** :
- ✅ Traitement de grandes quantités d'articles
- ✅ Import facile depuis Excel/Google Sheets
- ✅ Export depuis bases de données
- ✅ Rapport détaillé avec compteurs de succès/échecs

---

## 🔮 Évolutions futures

### Priorité 1 : Améliorations Google Sheets

- [ ] **Pagination des extractions** : Afficher plus de 20 extractions avec scroll infini
- [ ] **Filtres** : Filtrer par date, startup, montant avant export
- [ ] **Formatage Google Sheets** : Appliquer des styles (headers en gras, couleurs)
- [ ] **Gestion multi-feuilles** : Exporter vers différents onglets selon critères
- [ ] **Historique des exports** : Tracer qui a exporté quoi et quand

### Priorité 2 : Export WordPress

**Objectifs**
- Réinjecter les données extraites dans WordPress
- Choix du site de destination
- Rapport de succès détaillé

**Options à configurer** (selon vos besoins futurs)

1. **Action sur les données extraites**
   - [ ] Créer de nouveaux articles
   - [ ] Enrichir les articles existants avec custom fields
   - [ ] Les deux (dual mode)

2. **Format d'export**
   - [ ] Article texte formaté (HTML/Markdown)
   - [ ] Tableau HTML structuré
   - [ ] Custom fields ACF (Advanced Custom Fields)
   - [ ] Custom Post Type dédié "Levées de fonds"

3. **Destination WordPress**
   - [ ] Même multisite que la source
   - [ ] Site centralisé différent
   - [ ] Choix manuel par export

4. **Statut des articles créés**
   - [ ] Brouillon (pour validation manuelle)
   - [ ] Publié directement
   - [ ] Privé
   - [ ] Programmé (scheduled)

### Priorité 3 : Améliorations générales

- [ ] **Pagination WordPress** : Charger plus de 100 articles
- [ ] **Export CSV/Excel** : Format tableur en plus de JSON
- [ ] **Webhooks** : Import automatique lors de nouvelles publications WP
- [ ] **API REST** : Exposer l'extraction comme service
- [ ] **Dashboard analytics** : Statistiques sur les levées de fonds
- [ ] **Multi-langue** : Support i18n (FR/EN/ES)
- [ ] **Historique comparatif** : Détecter les changements entre versions

### Priorité 4 : Scalabilité

#### Pour le LLM
- [ ] File d'attente (Celery/RQ) pour traitement asynchrone
- [ ] Load balancing entre plusieurs instances LLM
- [ ] Cache intelligent (Redis) pour articles similaires
- [ ] Passage à GPU pour modèles lourds
- [ ] Support multi-providers (OpenAI, Anthropic, Gemini)

#### Pour l'application
- [ ] Déploiement Docker + Docker Compose
- [ ] CI/CD (GitHub Actions)
- [ ] Streamlit Cloud ou serveur dédié
- [ ] PostgreSQL géré (AWS RDS, Supabase, etc.)
- [ ] Monitoring (Sentry, Datadog)

---

## 📁 Structure du projet

```
sprint_Ai_final/
├── 📄 app.py                      # Application Streamlit principale
├── 📄 run_extraction.py           # Script CLI batch
├── 📄 database.py                 # Gestion PostgreSQL
├── 📄 wordpress_connector.py      # Connecteur WordPress REST API
├── 📄 prompt_manager.py           # Gestionnaire de prompts prédéfinis
├── 📄 system_prompt.txt           # Prompt LLM par défaut (fallback)
├── 📄 requirements.txt            # Dépendances Python
├── 📄 .env.example                # Template configuration LLM
├── 📄 .env                        # Configuration LLM (gitignored)
├── 📄 credentials.json            # Service Account Google (gitignored)
├── 📄 README.md                   # Ce fichier
├── 📄 test_wordpress_connection.py # Script de test WP
│
├── 📁 prompts/                    # Prompts système prédéfinis
│   ├── prompts_config.json        # Configuration des prompts
│   ├── levee_fonds_esante.txt     # Prompt e-santé (défaut)
│   ├── levee_fonds_fintech.txt    # Prompt fintech
│   ├── levee_fonds_retail.txt     # Prompt retail
│   └── analyse_generale.txt       # Prompt généraliste
│
├── 📁 .streamlit/
│   └── secrets.toml               # Config PostgreSQL (gitignored)
│
├── 📁 a_traiter/                  # Input : fichiers à traiter (CLI)
├── 📁 traites/                    # Output : fichiers traités (CLI)
│   ├── article1.txt
│   ├── article2.txt
│   └── article_test_1.txt
│
└── 📁 venv/                       # Environnement virtuel Python
```

---

## 🛡️ Sécurité

- ✅ Mots de passe hachés avec bcrypt (coût 12)
- ✅ Secrets PostgreSQL dans `secrets.toml` (gitignored)
- ✅ Clés API dans `.env` (gitignored)
- ✅ Credentials Google dans `credentials.json` (gitignored)
- ✅ Validation des entrées utilisateur
- ✅ URL source obligatoire pour traçabilité
- ✅ Contrainte UNIQUE sur `(user_id, content_hash)` → pas de duplicata
- ⚠️ Pour production :
  - Ajouter HTTPS (reverse proxy nginx)
  - Limiter les tentatives de connexion (rate limiting)
  - Activer les logs d'audit
  - Chiffrer les données sensibles en base
  - Rotation des clés API

---

## 🤝 Support

Pour toute question ou demande d'évolution :

1. **Issues GitHub** : Ouvrir une issue sur le dépôt
2. **Documentation** : Consulter les commentaires dans le code
3. **Configuration LLM** : Voir la documentation OpenAI ou LM Studio

---

## 📝 Licence

Ce projet est à usage interne. Tous droits réservés.

---

## 🙏 Crédits

**Technologies utilisées :**
- [Streamlit](https://streamlit.io/) - Interface web
- [PostgreSQL](https://www.postgresql.org/) - Base de données
- [OpenAI API](https://platform.openai.com/) - LLM cloud
- [LM Studio](https://lmstudio.ai/) - LLM local (optionnel)
- [WordPress REST API](https://developer.wordpress.org/rest-api/) - Source de données
- [Google Sheets API](https://developers.google.com/sheets/api) - Export de données
