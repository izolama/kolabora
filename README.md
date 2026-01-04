# kolabora – Private Collaboration Network

Flutter + Riverpod + go_router + Supabase. Fokus MVP: intent feed (owner/vendor), aplikasi, workspace, profil, dan undangan.

## Stack
- Flutter (Material 3, beberapa adaptasi iOS)
- State: Riverpod AsyncNotifier
- Routing: go_router (custom fade+slide transitions)
- Backend: Supabase (Auth, Postgres, Storage)
- Forms: flutter_form_builder (opsional di layar lain)

## Setup
1. Install dependency:
   ```bash
   flutter pub get
   ```
2. Supabase env saat run:
   ```bash
   flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```
3. Terapkan schema + RLS:
   - Jalankan SQL di `supabase/schema.sql` (atau jalankan per blok).
   - Jika pernah menerapkan sebelumnya, pastikan policy `workspace_members` memakai:
     ```sql
     drop policy if exists "Members manage workspace_members" on public.workspace_members;
     create policy "Members manage their workspace_members rows"
       on public.workspace_members for all
       using (auth.uid() = member_id);
     ```
4. Seed data awal:
   - Tambah beberapa `fields` (nama bidang layanan).
   - Tambah `profiles` yang terkait user auth (`id` = auth.users.id).
   - Buat `workspace_members` baris untuk user agar Workspaces muncul.

## Jalur utama aplikasi
- Auth: email/password (login screen) → Profile setup (/profile/setup) → Feed.
- Feed: filter tipe + “Open only” + field chips, search lokal; buka detail intent; Apply/Invite.
- Invite: pemilik intent membuka sheet, memilih profil lain → membuat application status `invited`.
- Workspaces: daftar workspace berdasarkan membership; buka detail workspace (tab Discussion/Files/Progress).
- Network Directory: daftar profil Supabase (search lokal).
- Profile: lihat profil sendiri atau profil lain via `/profile/:id`.

## Run & Build
```
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## Catatan RLS
Pastikan policy di `supabase/schema.sql` diterapkan; policy lama yang rekursif di `workspace_members` harus diganti seperti di atas.

## Struktur
```
lib/
  app/ (router, theme, bootstrap)
  core/ (supabase client, utils, ui components)
  features/
    auth, feed, network, profile, projects (applications), workspaces
```

## To-do pendek
- Supabase seeding otomatis (fields, sample profiles).
- Workspace list bisa ditambah pagination/join title dari post jika diperlukan.
- Diskusi workspace masih placeholder (pesan lokal) → sambungkan ke tabel `workspace_messages`.
