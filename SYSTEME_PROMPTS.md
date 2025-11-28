# 📝 Système de Prompts Prédéfinis

## ✅ Changement Important

**L'édition manuelle du prompt système a été supprimée pour plus de sécurité.**

Désormais, les utilisateurs choisissent parmi des prompts prédéfinis selon leur besoin.

## 🎯 Prompts Disponibles

### 1. 🏥 Levées de fonds - E-santé (par défaut)
- **Fichier** : `prompts/levee_fonds_esante.txt`
- **Usage** : Extraction pour start-ups de la e-santé
- **Exemples** : 7 exemples d'articles Health

### 2. 💰 Levées de fonds - Fintech
- **Fichier** : `prompts/levee_fonds_fintech.txt`
- **Usage** : Extraction pour start-ups fintech
- **Adapté** : Secteur financier et paiements

### 3. 🛍️ Levées de fonds - Retail
- **Fichier** : `prompts/levee_fonds_retail.txt`
- **Usage** : Extraction pour start-ups du retail
- **Adapté** : E-commerce et distribution

### 4. 📊 Levées de fonds - Général
- **Fichier** : `prompts/levee_fonds_general.txt`
- **Usage** : Tous secteurs confondus
- **Universel** : Pour articles variés

## 🔧 Comment Utiliser

### Dans l'Application Streamlit

1. Connectez-vous
2. Cliquez sur **Configuration** dans la sidebar
3. Ouvrez **"📝 Modèle d'extraction"**
4. Choisissez le modèle adapté à votre tâche
5. Cliquez sur **"✅ Appliquer ce modèle"**

Le choix est sauvegardé pour l'utilisateur.

## 🛠️ Pour les Développeurs

### Ajouter un Nouveau Prompt

1. **Créer le fichier prompt** :
   ```bash
   touch prompts/mon_nouveau_prompt.txt
   ```

2. **Ajouter la configuration** dans `prompts/prompts_config.json` :
   ```json
   {
     "id": "mon_nouveau_prompt",
     "name": "Mon Nouveau Prompt",
     "description": "Description du prompt",
     "file": "mon_nouveau_prompt.txt",
     "icon": "🎯"
   }
   ```

3. **Redémarrer l'application** : Le nouveau prompt apparaîtra automatiquement

### Structure du Système

```
prompts/
├── prompts_config.json         # Configuration des prompts
├── levee_fonds_esante.txt     # Prompt e-santé
├── levee_fonds_fintech.txt    # Prompt fintech
├── levee_fonds_retail.txt     # Prompt retail
└── levee_fonds_general.txt    # Prompt général

prompt_manager.py               # Gestionnaire de prompts
```

## 🔒 Sécurité

✅ **Avantages du nouveau système** :
- Pas de risque de casser l'application avec un prompt invalide
- Prompts testés et validés
- Cohérence des extractions
- Facile à maintenir et étendre

❌ **Ancien système (supprimé)** :
- Édition libre du prompt
- Risque d'erreurs JSON
- Pas de validation
- Difficile à débugger

## 📊 Base de Données

**Colonne** : `users.selected_prompt_id`
- Type : `VARCHAR(50)`
- Défaut : `'levee_fonds_esante'`
- Valeurs possibles : Les IDs définis dans `prompts_config.json`

## 🎨 Interface Utilisateur

Le sélecteur affiche :
- 🏥 **Icône** du prompt
- **Nom** du modèle
- **Description** détaillée

Simple et sécurisé !
