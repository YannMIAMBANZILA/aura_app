-- Ajout de la colonne pour stocker le détail des réponses (questions posées + choix de l'élève)
alter table public.study_sessions 
add column if not exists answers_json jsonb;

-- Commentaires pour documentation
comment on column public.study_sessions.answers_json is 'Stocke la liste des questions et objets réponses pour review';

-- RLS (Sécurité) - On réaffirme que l'utilisateur peut voir ses propres sessions (déjà existant normalement, mais bon rappel)
-- create policy "Users can view their own sessions" on public.study_sessions for select using ( auth.uid() = user_id );
