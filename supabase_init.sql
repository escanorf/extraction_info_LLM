-- ========================================
-- Script d'initialisation de la base de données Supabase
-- ========================================
-- Ce script crée toutes les tables nécessaires pour l'application
-- À exécuter dans Supabase : Dashboard > SQL Editor > New Query

-- Suppression des tables existantes (optionnel - décommenter si besoin de réinitialiser)
-- DROP TABLE IF EXISTS extractions CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;

-- ========================================
-- Table des utilisateurs
-- ========================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    selected_prompt_id VARCHAR(50) DEFAULT 'levee_fonds_esante',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances de recherche par username
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- ========================================
-- Table des extractions
-- ========================================
CREATE TABLE IF NOT EXISTS extractions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    original_content TEXT,
    extracted_data JSONB,
    content_hash VARCHAR(64),
    source_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT unique_user_content UNIQUE (user_id, content_hash)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_extractions_user_id ON extractions(user_id);
CREATE INDEX IF NOT EXISTS idx_extractions_created_at ON extractions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_extractions_content_hash ON extractions(content_hash);

-- Index GIN pour recherche rapide dans les données JSON
CREATE INDEX IF NOT EXISTS idx_extractions_data ON extractions USING GIN (extracted_data);

-- ========================================
-- Politiques de sécurité Row Level Security (RLS)
-- ========================================
-- Activer RLS sur les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE extractions ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre à tous de créer un compte (signup)
CREATE POLICY "Permettre création de compte" ON users
    FOR INSERT
    WITH CHECK (true);

-- Politique pour permettre aux utilisateurs de voir leur propre profil
CREATE POLICY "Utilisateurs peuvent voir leur profil" ON users
    FOR SELECT
    USING (id = current_setting('app.current_user_id', true)::INTEGER);

-- Politique pour permettre aux utilisateurs de modifier leur profil
CREATE POLICY "Utilisateurs peuvent modifier leur profil" ON users
    FOR UPDATE
    USING (id = current_setting('app.current_user_id', true)::INTEGER);

-- Politique pour permettre aux utilisateurs de créer leurs extractions
CREATE POLICY "Utilisateurs peuvent créer des extractions" ON extractions
    FOR INSERT
    WITH CHECK (user_id = current_setting('app.current_user_id', true)::INTEGER);

-- Politique pour permettre aux utilisateurs de voir leurs extractions
CREATE POLICY "Utilisateurs peuvent voir leurs extractions" ON extractions
    FOR SELECT
    USING (user_id = current_setting('app.current_user_id', true)::INTEGER);

-- Politique pour permettre aux utilisateurs de mettre à jour leurs extractions
CREATE POLICY "Utilisateurs peuvent modifier leurs extractions" ON extractions
    FOR UPDATE
    USING (user_id = current_setting('app.current_user_id', true)::INTEGER);

-- Politique pour permettre aux utilisateurs de supprimer leurs extractions
CREATE POLICY "Utilisateurs peuvent supprimer leurs extractions" ON extractions
    FOR DELETE
    USING (user_id = current_setting('app.current_user_id', true)::INTEGER);

-- ========================================
-- Fonction pour nettoyer les anciennes extractions (optionnel)
-- ========================================
CREATE OR REPLACE FUNCTION delete_old_extractions()
RETURNS void AS $$
BEGIN
    -- Supprime les extractions de plus de 1 an
    DELETE FROM extractions
    WHERE created_at < NOW() - INTERVAL '1 year';
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- Statistiques et vues (optionnel)
-- ========================================
-- Vue pour voir les statistiques par utilisateur
CREATE OR REPLACE VIEW user_stats AS
SELECT
    u.id,
    u.username,
    u.created_at as user_created_at,
    COUNT(e.id) as total_extractions,
    MAX(e.created_at) as last_extraction_date
FROM users u
LEFT JOIN extractions e ON u.id = e.user_id
GROUP BY u.id, u.username, u.created_at;

-- ========================================
-- Données de test (optionnel - décommenter pour créer un utilisateur de test)
-- ========================================
-- ATTENTION : Ne pas utiliser en production !
-- INSERT INTO users (username, password_hash, selected_prompt_id) VALUES
-- ('test_user', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5jtJ3qVqhfldG', 'levee_fonds_esante');
-- Mot de passe : "test123"

-- ========================================
-- Vérification de l'installation
-- ========================================
-- Afficher un résumé des tables créées
SELECT
    'Tables créées avec succès !' as message,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') as users_table,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'extractions') as extractions_table;
