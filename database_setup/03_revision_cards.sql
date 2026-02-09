-- Create revision_cards table
CREATE TABLE IF NOT EXISTS revision_cards (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  subject TEXT NOT NULL,
  chapter TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE revision_cards ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own revision cards" 
ON revision_cards FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own revision cards" 
ON revision_cards FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own revision cards" 
ON revision_cards FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own revision cards" 
ON revision_cards FOR DELETE 
USING (auth.uid() = user_id);
