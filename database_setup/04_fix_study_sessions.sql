-- Correction de la table study_sessions pour supporter les statistiques
ALTER TABLE public.study_sessions 
ADD COLUMN IF NOT EXISTS "subject" TEXT;

-- Index pour accélérer les requêtes par utilisateur et matière
CREATE INDEX IF NOT EXISTS idx_study_sessions_user_subject ON public.study_sessions(user_id, subject);

-- Assurer que RLS est actif et permet la lecture/écriture
ALTER TABLE public.study_sessions ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes politiques si elles existent pour éviter les doublons
DROP POLICY IF EXISTS "Users can view their own sessions" ON public.study_sessions;
DROP POLICY IF EXISTS "Users can insert their own sessions" ON public.study_sessions;

-- Création des politiques de sécurité
CREATE POLICY "Users can view their own sessions" 
ON public.study_sessions FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sessions" 
ON public.study_sessions FOR INSERT 
WITH CHECK (auth.uid() = user_id);
