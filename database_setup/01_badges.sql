-- Création de la table des badges
create table public.badges (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  badge_type text not null, -- 'Hebdo', 'Mensuel', 'Trimestriel', 'Semestriel', 'Annuel'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  -- S'assurer qu'un utilisateur n'a pas 2 fois le même badge (Optionnel mais recommandé)
  unique(user_id, badge_type)
);

-- Sécurité Row Level Security (RLS)
alter table public.badges enable row level security;

-- Politique : Tout le monde peut lire (ou juste le propriétaire, selon ton choix)
create policy "Users can view their own badges"
on public.badges for select
using ( auth.uid() = user_id );

-- Politique : Seul le système (ou fonctions) peut insérer, but for client-side easier dev:
-- create policy "Users can insert their own badges" on public.badges for insert with check ( auth.uid() = user_id );

-- EXEMPLES D'INSERTION POUR TESTER RAPIDEMENT :
-- Remplace 'ID_UTILISATEUR' par ton vrai ID Supabase (visible dans Authentication > Users)

-- insert into public.badges (user_id, badge_type) values ('ID_UTILISATEUR', 'Hebdo');
-- insert into public.badges (user_id, badge_type) values ('ID_UTILISATEUR', 'Mensuel');
