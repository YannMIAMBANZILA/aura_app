-- Ajouter une colonne grade_level à la table profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS grade_level text;
