-- Forum Gönderileri Tablosunu Oluştur
CREATE TABLE IF NOT EXISTS public.forum_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_email TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('sikayet', 'oneri', 'soru', 'genel')),
    car_brand TEXT NOT NULL, -- Boş geçilemez yapıldı
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- RLS (Row Level Security) Politikalarını Etkinleştir
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

-- Politikalar: Herkes okuyabilir, sadece giriş yapanlar yazabilir
CREATE POLICY "Forum gönderilerini herkes görebilir" ON public.forum_posts FOR SELECT USING (true);
CREATE POLICY "Sadece giriş yapanlar gönderi oluşturabilir" ON public.forum_posts FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Kullanıcılar sadece kendi gönderilerini silebilir" ON public.forum_posts FOR DELETE USING (auth.uid() = user_id);
