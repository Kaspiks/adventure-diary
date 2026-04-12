# Rīgas Motormuzeja Trivia Izaicinājums — Stitch Prototipa Specifikācija

## Pārskats

Šī specifikācija definē pilnu lietotāja plūsmu gamificētā ceļojumu platformā "Adventure Diary". Galvenais scenārijs: lietotājs atklāj lokācijā balstītu trivia izaicinājumu Rīgas Motormuzejā, pabeidz to, saņem punktus un apmaina tos pret atlīdzību.

**Vizuālais stils:** Dark theme (slate-900 bāze), gradient akcenti (emerald/teal primārais, amber/orange sekundārais), glassmorphism efekti, Tailwind CSS.

---

## 1. UX Plūsma (User Journey)

```
Login → Dashboard → Challenge List → Challenge Details → Start →
→ Active Attempt (5 uzdevumi) → Submit → Waiting for Review →
→ Approved (punkti piešķirti) → Reward Catalogue → Purchase Reward →
→ Order Created → Order Fulfilled
```

### Soļi detalizēti:

| # | Solis | Lietotāja mērķis | Sistēmas reakcija | Nākamais |
|---|-------|-------------------|-------------------|----------|
| 1 | **Login** | Pieslēgties platformai | Autentifikācija, redirect uz Dashboard | Dashboard |
| 2 | **Dashboard** | Redzēt pārskatu | Statistika, aktīvie izaicinājumi, aktivitāte, līderu tabula | Challenge List |
| 3 | **Challenge List** | Atrast izaicinājumu | Kartiņu režģis ar filtriem | Challenge Details |
| 4 | **Challenge Details** | Saprast, kas jādara | Apraksts, noteikumi, ģeožoga brīdinājums, CTA | Start |
| 5 | **Start** | Sākt izaicinājumu | Sistēma izveido attempt, redirect uz Attempt | Attempt |
| 6 | **Active Attempt** | Izpildīt uzdevumus | 5 progresīvi lauki: teksts, izvēles, foto | Submit |
| 7 | **Submit** | Iesniegt atbildes | Validācija, ģeožogs, statusa maiņa | Waiting |
| 8 | **Waiting** | Gaidīt apstiprināšanu | "Submitted" statuss, atbilžu pārskats | Approved |
| 9 | **Approved** | Redzēt rezultātu | Punktu sadalījums, "Next Steps" bloks | Rewards |
| 10 | **Reward Catalogue** | Atrast atlīdzību | Kartiņas ar cenām, pieejamību | Reward Details |
| 11 | **Reward Details** | Nopirkt atlīdzību | Cena, apraksts, "Purchase" poga | Order |
| 12 | **Order** | Redzēt statusu | Laika līnija: Pending → Approved → Delivered | Done |

---

## 2. Ekrānu Definīcijas

### Screen 01: Login

- **screen_name:** `login`
- **purpose:** Lietotāja autentifikācija
- **layout:** Centrēts, bez navbar, pilnekrāna gradient fons (emerald → teal → cyan)
- **key_elements:**
  - App logo (amber/orange gradient aplis ar kartes ikonu)
  - App nosaukums "Adventure Diary" + apakšvirsraksts
  - Glassmorphism karte (bg-white/10, backdrop-blur)
  - E-pasta lauks
  - Paroles lauks + "Aizmirsi paroli?" saite
  - "Atcerēties mani" checkbox
  - "Pieslēgties" poga (amber → orange gradient, pilna platuma)
  - Reģistrācijas saite apakšā
- **primary_action:** Pieslēgties
- **secondary_actions:** Aizmirsi paroli, Reģistrēties
- **user_state:** Neautentificēts

---

### Screen 02: Dashboard (Home)

- **screen_name:** `dashboard`
- **purpose:** Centrālais pārskats par lietotāja progresu
- **layout:** Navbar augšā + 4 statistikas kartiņas + 3 kolonnu saturs
- **key_elements:**
  - **Navbar:** Logo + app nosaukums, punktu pills (amber), lietotāja vārds, Admin saite (ja ir loma), Sign out. Mobilajā: hamburger ar izvēlni
  - **4 Statistikas kartiņas** (2x2 mobilajā, 4 rindā desktop):
    - Punkti (amber gradient) — `95 pts`
    - Aktīvie izaicinājumi (emerald gradient) — `1`
    - Pabeigti (cyan gradient) — `2`
    - Atlīdzības (purple gradient) — `1`
  - **Aktīvie izaicinājumi** (2/3 platuma): saraksts ar challenge nosaukumiem, tipiem, punktu vērtībām, "View All" saite
  - **Nesenā aktivitāte:** attempt saraksts ar krāsainiem statusa indikatoriem (zils=started, dzeltens=submitted, zaļš=approved, sarkans=rejected), laiku "pirms X"
  - **Ātrās darbības** (1/3 platuma): ikoniskas saites (Challenges, Rewards, My Attempts, Profile)
  - **Līderu tabula:** Top lietotāji ar vietu, avatāru, vārdu, punktiem. #1 ar zeltu
- **primary_action:** Atvērt izaicinājumu
- **secondary_actions:** Skatīt atlīdzības, Mani mēģinājumi, Profils
- **data_shown:** Punktu bilance, aktīvo/pabeigto izaicinājumu skaits, nesenie mēģinājumi
- **user_state:** Autentificēts, jebkurš

---

### Screen 03: Challenge List

- **screen_name:** `challenge_list`
- **purpose:** Pārlūkot pieejamos izaicinājumus
- **layout:** Atpakaļ poga uz Dashboard, virsraksts + skaits, 3 kolonnu kartiņu režģis
- **key_elements:**
  - Virsraksts "Challenges" + "X izaicinājumi pieejami"
  - **Challenge Card** (atkārtots komponents):
    - Tipa badge (krāsains pills: "Exploration" emerald)
    - Punktu vērtība (emerald, bold) — "50 pts"
    - Nosaukums (bold, balts)
    - Apraksta fragments (2 rindas, line-clamp, slate-400)
    - Lokācija ar kartes ikonu — "Riga Motor Museum"
    - Grūtības pakāpe ar zvaigznes ikonu — "Medium"
    - CTA poga "Skatīt detaļas" (emerald → teal gradient, pilna platuma)
  - Tukšs stāvoklis: kartes ikona + "Nav izaicinājumu" teksts
- **primary_action:** Atvērt challenge
- **user_state:** Autentificēts

---

### Screen 04: Challenge Details

- **screen_name:** `challenge_details`
- **purpose:** Detalizēta informācija par izaicinājumu pirms sākšanas
- **layout:** Atpakaļ uz Challenge List, viena karte ar visu saturu
- **key_elements:**
  - **Header zona:**
    - Tipa badge ("Exploration", emerald pills)
    - Grūtības badge ("Medium", slate pills)
    - Nosaukums: "Rīgas Motormuzeja Trivia Izaicinājums" (2xl-3xl, bold, balts)
    - Punkti: "50 pts" (emerald, 2xl-3xl, bold) + "Reward" zem tā
  - **Info režģis** (2 kolonnas):
    - Lokācija ar kartes ikonu: "Riga Motor Museum"
    - Veidotājs ar lietotāja ikonu: "Company Manager"
  - **Ģeožoga brīdinājums** (ja lokācija ir ģeofenced):
    - Amber fons ar brīdinājuma ikonu
    - "Nepieciešama atrašanās lokācijā" — "Jāatrodas 200m no Riga Motor Museum"
  - **Apraksts** (whitespace-pre-wrap):
    - Vairāku rindkopas teksts ar bullet punktiem
    - Laika aplēse, instrukcijas
  - **CTA zona** (border-top):
    - **Stāvoklis "nav mēģinājuma":** zaļa gradient poga "Sākt izaicinājumu" (pilna platuma)
    - **Stāvoklis "jau sākts":** dzeltens teksts "Jau sākts" + saite "Skatīt manu mēģinājumu"
    - **Stāvoklis "apstiprināts":** zaļš teksts "Pabeigts" + "Nopelnīti 95 punkti"
    - **Stāvoklis "noraidīts":** sarkans teksts + "Mēģināt vēlreiz" poga
- **primary_action:** Sākt izaicinājumu / Turpināt
- **user_state:** no_attempt / started / approved / rejected

---

### Screen 05: Active Attempt (Submit Flow)

- **screen_name:** `attempt_submit`
- **purpose:** Izpildīt uzdevumus un iesniegt atbildes
- **layout:** Atpakaļ uz My Attempts, izaicinājuma nosaukums + statusa badge, lauku forma
- **key_elements:**
  - **Header:** Challenge nosaukums + statusa pills ("Started" — zils)
  - **Laika informācija:** Sākts: datums/laiks, Iesniegts: "-"
  - **Ģeožoga sekcija** (ja geofenced):
    - Karte (Leaflet) ar rādiusa apli
    - "Nepieciešama lokācija" teksts + "Atjaunot lokāciju" poga
    - Statusa indikators: "Pārbauda lokāciju..." (amber) → "Esat lokācijā!" (zaļš) / "Ārpus zonas" (sarkans)
    - Slēptie lauki user_latitude / user_longitude
  - **Uzdevumu forma** (`form_with`, multipart):
    - **Katram laukam (field_wrapper):**
      - Label ar obligātuma zvaigznīti (*)
      - Instrukciju teksts (slate-400, mazāks fonts)
      - Punktu badge ("10 points", emerald pills ar zvaigznes ikonu)
      - Lauka specifiskais komponents (skat. zemāk)
    - **5 lauki secībā:**
      1. `text_input` — "1. solis · Muzeja Pirmsākumi" (teksta ievade)
      2. `single_choice` — "2. solis · Padomju Garāža" (radio pogas)
      3. `multiple_choice` — "3. solis · Baltijas Automobiļu Mantojums" (checkboxes)
      4. `photo_upload` — "4. solis · Tavs Muzeja Mirklis" (foto augšupielāde x3 + paraksti)
      5. `text_input` — "5. solis · Leģenda uz Trases" (teksta ievade)
  - **Submit poga:**
    - Ja geofenced un nav lokācijā: disabled, opacity-50, cursor-not-allowed
    - Ja lokācija OK vai nav geofence: aktīva emerald gradient poga
- **primary_action:** Iesniegt izaicinājumu
- **user_state:** started

---

### Screen 06: Attempt — Submitted (Waiting)

- **screen_name:** `attempt_submitted`
- **purpose:** Informēt lietotāju, ka atbildes gaida pārskatīšanu
- **layout:** Tāds pats kā attempt show, bet ar submitted stāvokli
- **key_elements:**
  - Statusa badge: "Submitted" (amber pills)
  - **Augšupielādētie foto:** 2-3 kolonnu režģis ar mazām bildēm, lauka nosaukumu overlay, parakstu
  - **Jūsu atbildes sekcija:**
    - Katrai atbildei: lauka nosaukums, atbildes teksts, "Gaida pārskatīšanu" (amber)
    - "Rediģēt atbildes" saite (ja vēl nav final)
  - Nav Submit pogas (jau iesniegts)
  - Nav Review pogas (tikai challenge owner/admin redz)
- **primary_action:** Nav (gaidīšana)
- **secondary_actions:** Rediģēt atbildes
- **user_state:** submitted

---

### Screen 07: Attempt — Approved (Result)

- **screen_name:** `attempt_approved`
- **purpose:** Parādīt rezultātu un nopelnītos punktus
- **layout:** Tāds pats kā attempt show, bet ar approved stāvokli
- **key_elements:**
  - Statusa badge: "Approved" (emerald pills)
  - **Punktu displejs:** "+95" (emerald, 2xl-3xl, bold) + "Points earned"
  - **Quiz Score:** "Quiz Score: 45/45" (mazāks, slate-500)
  - Pārskatīšanas informācija: Reviewed datums, Reviewer vārds
  - **Augšupielādētie foto** (kā submitted)
  - **Atbilžu pārskats:**
    - Katra atbilde ar zaļu ✓ vai sarkanu ✗
    - Pareiza: "✓ 10/10 pts" (emerald)
    - Nepareiza: "✗ 0/10 pts" (sarkans)
  - **"Next Steps" bloks** (border-top):
    - Virsraksts "Kas tālāk?"
    - Teksts "Apsveicam! Izmanto savus punktus..."
    - Divas pogas: "Pārlūkot izaicinājumus" (gradient) + "Skatīt atlīdzības" (slate)
- **primary_action:** Skatīt atlīdzības
- **secondary_actions:** Pārlūkot izaicinājumus
- **user_state:** approved

---

### Screen 08: Attempt — Review (Company/Admin skats)

- **screen_name:** `attempt_review`
- **purpose:** Ļaut challenge owner pārskatīt un apstiprināt iesniegumu
- **layout:** Tāds pats kā attempt show, bet ar review kontrolēm
- **key_elements:**
  - Virsraksts "Pārskatīt mēģinājumu"
  - **Iesniegtās atbildes:**
    - Katra atbilde kartiņā: lauka nosaukums, atbildes teksts
    - Pareizas atbildes ar emerald fonu/apmali
    - Punktu sadalījums: "✓ 10/10 pts" vai "✗ 0/10 pts"
  - **Augšupielādētie foto** ar parakstiem
  - **Darbību pogas** (flexbox, 2 kolonnas):
    - "Apstiprināt" (emerald poga) → atver modālo logu
    - "Noraidīt" (sarkana poga) → atver modālo logu
  - **Apstiprinājuma modālais logs:**
    - Zaļa ikona + virsraksts "Apstiprināt"
    - Apstiprinājuma teksts
    - "Atcelt" (slate) + "Apstiprināt" (emerald) pogas
  - **Noraidīšanas modālais logs:**
    - Sarkana ikona + virsraksts "Noraidīt"
    - Apstiprinājuma teksts
    - "Atcelt" (slate) + "Noraidīt" (sarkana) pogas
- **primary_action:** Apstiprināt
- **secondary_actions:** Noraidīt
- **user_state:** submitted (company/admin skatā)

---

### Screen 09: My Attempts

- **screen_name:** `my_attempts`
- **purpose:** Lietotāja mēģinājumu saraksts
- **layout:** Atpakaļ uz Challenges, virsraksts + skaits, attempt saraksts
- **key_elements:**
  - Virsraksts "Mani mēģinājumi" + skaits
  - **Attempt Card** (atkārtots):
    - Challenge nosaukums (bold, balts)
    - Statusa badge (krāsains pills)
    - Sākšanas datums
    - Nopelnītie punkti (ja ir): "+95 pts" emerald
    - "Skatīt detaļas" saite ar bultiņu
  - Tukšs stāvoklis: "Nav mēģinājumu" + saite uz Challenges
- **primary_action:** Atvērt attempt
- **user_state:** Autentificēts

---

### Screen 10: Reward Catalogue

- **screen_name:** `reward_list`
- **purpose:** Pārlūkot pieejamās atlīdzības
- **layout:** Atpakaļ uz Dashboard, virsraksts + skaits, punktu bilance, 3 kolonnu režģis
- **key_elements:**
  - Header ar virsrakstu "Atlīdzības" + skaits
  - **Punktu bilance** (labajā pusē): "Jūsu punkti: 95 pts" (emerald, bold)
  - **Reward Card** (atkārtots komponents):
    - Attēls vai placeholder (gift ikona uz slate fona) — h-32/40
    - Statusa badge ("Active", emerald)
    - Cena: "75 pts" (emerald, bold)
    - Nosaukums (bold, balts)
    - Apraksta fragments (2 rindas, line-clamp)
    - Piedāvātājs ar lietotāja ikonu
    - Krājuma statuss ar paku ikonu: "50 left" (emerald) / "Out of Stock" (sarkans)
    - CTA poga:
      - Ja var atļauties: emerald gradient "Skatīt detaļas"
      - Ja nevar: slate poga "Skatīt detaļas"
  - Tukšs stāvoklis: "Nav atlīdzību"
- **primary_action:** Atvērt atlīdzību
- **data_shown:** Punktu bilance, cenas, krājumi
- **user_state:** Autentificēts

---

### Screen 11: Reward Details

- **screen_name:** `reward_details`
- **purpose:** Detalizēta informācija + pirkšanas darbība
- **layout:** Atpakaļ uz Rewards, viena karte ar visu saturu
- **key_elements:**
  - Attēls augšā (h-64, ja ir) vai tukšs
  - **Header:**
    - Statusa badge + krājuma badge
    - Nosaukums (3xl, bold, balts)
    - Cena: "75 pts" (emerald, 3xl, bold) + "Cost" teksts
  - **Info režģis** (2 kolonnas):
    - Piedāvātājs (lietotāja ikona)
    - Jūsu bilance: "20 pts" (pulksteņa ikona)
  - **Apraksts** (HTML renderēts):
    - Teksta rindkopas, bullet saraksti, emphasis
  - **CTA zona** (border-top):
    - **Var atļauties + aktīva + in stock:** "Nopirkt atlīdzību" gradient poga (pilna platuma)
    - **Out of stock:** sarkans teksts "Beidzies"
    - **Nav aktīva:** slate teksts "Nav pieejama"
    - **Nepietiek punktu:** dzeltens teksts "Nepietiek punktu" + "Vēl nepieciešami X punkti"
- **primary_action:** Nopirkt
- **user_state:** Autentificēts, ar/bez pietiekamiem punktiem

---

### Screen 12: Order Confirmation

- **screen_name:** `order_show`
- **purpose:** Parādīt pasūtījuma statusu un laika līniju
- **layout:** Atpakaļ uz Orders, viena karte
- **key_elements:**
  - **Header:**
    - Statusa badge (krāsains pills)
    - Atlīdzības nosaukums (3xl, bold)
    - Iztērētie punkti: "75 pts" (emerald, 3xl) + "Points spent"
  - **Info režģis:**
    - Pasūtīšanas datums (pulksteņa ikona)
    - Piedāvātājs (lietotāja ikona)
  - **Statusa laika līnija** (vertikāla):
    - ✓ Pasūtījums izveidots (zaļš, vienmēr redzams) + datums
    - ✓ Pasūtījums apstiprināts (zils, ja approved/delivered)
    - ✓ Pasūtījums izpildīts (zaļš, ja delivered)
    - ✗ Pasūtījums atcelts (sarkans, ja cancelled)
- **primary_action:** Nav (informatīvs)
- **user_state:** Autentificēts

---

### Screen 13: My Orders

- **screen_name:** `order_list`
- **purpose:** Lietotāja pasūtījumu saraksts
- **layout:** Atpakaļ uz Dashboard, virsraksts + skaits, pasūtījumu kartiņas
- **key_elements:**
  - Virsraksts "Mani pasūtījumi" + skaits
  - **Order Card** (atkārtots):
    - Statusa badge (krāsains)
    - Atlīdzības nosaukums (bold)
    - Datums
    - Iztērētie punkti
    - "Skatīt detaļas" saite
  - Tukšs stāvoklis: ikona + teksts + saite uz Rewards
- **primary_action:** Atvērt order
- **user_state:** Autentificēts

---

### Screen 14: Profile

- **screen_name:** `profile`
- **purpose:** Lietotāja personīgā informācija
- **layout:** Savs navbar (nav globālais), atpakaļ uz Dashboard, sidebar + saturs
- **key_elements:**
  - **Sticky mini-nav:** Atpakaļ poga, virsraksts "Profils", "Rediģēt" poga
  - **Sidebar:** Avatāra aplis (violet → purple gradient, iniciāļi), pilns vārds, e-pasts
  - **Informācijas karte:** Vārds, uzvārds, e-pasts, dalībnieks kopš
- **primary_action:** Rediģēt profilu
- **user_state:** Autentificēts

---

## 3. Atkārtoti Izmantojami Komponenti

### 3.1 Navbar
- Logo (amber gradient aplis + kartes ikona) + app nosaukums
- Punktu pills (amber fons, amber teksts)
- Lietotāja vārds
- Desktop: horizontālas saites | Mobile: hamburger + slide panel
- Saites: Home, Challenges, Rewards, My Orders, (Admin), Sign Out

### 3.2 Challenge Card
- Tipa badge (krāsains pills)
- Punktu vērtība (emerald bold)
- Nosaukums (balts bold)
- Apraksta fragments (slate-400, 2 rindas)
- Lokācija + kartes ikona
- Grūtība + zvaigznes ikona
- CTA poga (emerald gradient, pilna platuma)

### 3.3 Status Badge
- Vienkāršs pills komponents
- Krāsas pēc koda:
  - `started` → zils (bg-blue-500/20, text-blue-300)
  - `submitted` → dzeltens (bg-amber-500/20, text-amber-300)
  - `approved` → zaļš (bg-emerald-500/20, text-emerald-300)
  - `rejected` → sarkans (bg-red-500/20, text-red-300)
  - `pending` → dzeltens
  - `delivered` → zaļš
  - `cancelled` → sarkans

### 3.4 Stat Card
- Gradient fons (krāsa mainās)
- Label (mazāks, gaišāka krāsa)
- Vērtība (2xl bold balts)
- Ikona aplī (labajā pusē)

### 3.5 Reward Card
- Attēls / placeholder (gift ikona)
- Statusa badge + cena
- Nosaukums + apraksts
- Piedāvātājs + krājuma statuss
- CTA poga (gradient ja var atļauties, slate ja nevar)

### 3.6 Field Wrapper (uzdevuma lauks)
- Label ar * obligātuma zīmi
- Instrukciju teksts (mazāks, slate-400)
- Punktu badge (emerald pills ar zvaigznīti)
- Lauka specifiskais saturs (skat. zemāk)

### 3.7 Text Input Field
- Viena rinda teksta ievade
- Stils: slate-700 bg, slate-600 border, emerald focus ring
- Placeholder teksts

### 3.8 Single Choice Field
- Radio pogu saraksts
- Katra opcija: radio + label rindā, hover efekts
- Emerald radio krāsa

### 3.9 Multiple Choice Field
- Checkbox saraksts
- Katra opcija: checkbox + label rindā, hover efekts
- "Atzīmē visus pareizos" hint teksts

### 3.10 Photo Upload Field
- Esošo foto režģis (ja ir)
- Upload bloki (1 līdz max_photos):
  - Kameras ikona + "Foto X"
  - File input (emerald poga stils)
  - Caption teksta lauks (ja require_caption)
- Hint: "Augšupielādēt vismaz 1 (maks. 3)"

### 3.11 Geofence Map Block
- Kartes konteiners (Leaflet, h-48/72)
- Rādiusa aplis uz kartes
- Statusa teksts: pārbauda (amber) / iekšā (zaļš) / ārpus (sarkans)
- "Atjaunot lokāciju" poga

### 3.12 Confirmation Modal
- Overlay (black/60, backdrop-blur)
- Balta karte (slate-800)
- Ikona aplī (zaļa vai sarkana)
- Virsraksts + apstiprinājuma teksts
- Divas pogas: Atcelt (slate) + Darbība (krāsaina)

### 3.13 Order Timeline
- Vertikāls soļu saraksts
- Katrs solis: apaļa ikona (✓ vai ✗) + teksts + datums
- Krāsas: emerald (izpildīts), blue (process), red (atcelts)

---

## 4. Lietotāja Stāvokļu Modelis

### Challenge kontekstā:

| Stāvoklis | UI Challenge Details | UI Attempt |
|-----------|---------------------|------------|
| **no_attempt** | Zaļa "Sākt" poga | Nav |
| **started** | "Jau sākts" + saite uz attempt | Forma ar laukiem + Submit poga |
| **submitted** | "Jau sākts" + saite | Atbildes pārskats + "Gaida pārskatīšanu" |
| **approved** | "Pabeigts ✓" + punkti | Punktu sadalījums + Next Steps |
| **rejected** | "Noraidīts" + "Mēģināt vēlreiz" | Noraidīšanas informācija + saite atpakaļ |

### Reward kontekstā:

| Stāvoklis | UI Reward Details |
|-----------|------------------|
| **can_afford + active + in_stock** | Zaļa "Nopirkt" poga |
| **cannot_afford** | Dzeltens "Nepietiek punktu" + trūkstošais daudzums |
| **out_of_stock** | Sarkans "Beidzies" |
| **inactive** | Pelēks "Nav pieejama" |

### Order kontekstā:

| Stāvoklis | UI Order Show |
|-----------|--------------|
| **pending** | Timeline: 1 solis (izveidots) |
| **approved** | Timeline: 2 soļi (izveidots + apstiprināts) |
| **delivered** | Timeline: 3 soļi (izveidots + apstiprināts + izpildīts) |
| **cancelled** | Timeline: izveidots + atcelts (sarkans) |

---

## 5. Navigācijas Karte

```
[Login] → [Dashboard]
              ├── [Challenge List] → [Challenge Details] → [Start] → [Attempt]
              │                                                         ├── submit → [Attempt Submitted]
              │                                                         └── approved → [Attempt Approved]
              ├── [My Attempts] → [Attempt Show]
              ├── [Reward Catalogue] → [Reward Details] → [Purchase] → [Order Show]
              ├── [My Orders] → [Order Show]
              └── [Profile]
```

Navbar saites (vienmēr pieejamas): Home, Challenges, Rewards, My Orders

---

## 6. Gatavs Stitch Prompt

Nokopē šo tekstu un ieliec Google Stitch:

---

**STITCH PROMPT START**

Design a dark-themed gamified travel challenge web app called "Adventure Diary". The app uses a slate-900 gradient background with emerald/teal primary accents and amber/orange secondary accents. All cards use glassmorphism (bg-slate-800/50, border-white/10). The visual style is modern, dark, with rounded corners (rounded-xl/2xl) and gradient buttons.

The app demonstrates this user journey for "Rīgas Motormuzeja Trivia Izaicinājums" (Riga Motor Museum Trivia Quest):

**Screen 1 — Login**
Full-screen emerald-to-cyan gradient background with animated blurred circles. Centered glassmorphism card (bg-white/10, backdrop-blur). App logo: amber-to-orange gradient circle with map pin icon. Title "Adventure Diary" in white bold. Subtitle in emerald-200. Email input, password input with "Forgot password?" link, "Remember me" checkbox, full-width amber-to-orange gradient submit button "Sign In". Registration link below.

**Screen 2 — Dashboard**
Top sticky navbar: logo + app name, amber points pill showing "20 pts" with star icon, user name, sign out button. Mobile: hamburger menu. Below: 4 stat cards in a row — Points (amber, "20"), Active Challenges (emerald, "1"), Completed (cyan, "1"), Rewards Claimed (purple, "1"). Main content in 3-column grid: Left 2/3: "Active Challenges" list showing "Rīgas Motormuzeja Trivia Izaicinājums" with map-pin icon, type "Exploration Challenge", and "+50" points badge. Below: "Recent Activity" with attempt entries showing colored status badges (blue=Started, amber=Submitted, emerald=Approved). Right 1/3: "Quick Actions" with icon links (Challenges, Rewards, My Attempts, Profile). Below: "Leaderboard" showing top 5 users with rank numbers, avatar initials in gradient circles, names, and point counts with star icons.

**Screen 3 — Challenge List**
Back arrow to Dashboard. Title "Challenges" with count subtitle. 3-column card grid. Each challenge card: emerald "Exploration" type badge top-left, "50 pts" emerald bold top-right, challenge title in white bold, 2-line description truncated in slate-400, location with map-pin icon "Riga Motor Museum", difficulty with star icon "Medium", full-width emerald-to-teal gradient button "View Details".

**Screen 4 — Challenge Details**
Back to Challenge List. Single card layout. Top: "Exploration" badge + "Medium" badge, title "Rīgas Motormuzeja Trivia Izaicinājums" in 3xl white bold. Right side: "50 pts" in 3xl emerald bold. Info grid: location "Riga Motor Museum" with map-pin, creator name with user icon. Amber warning box: map-pin icon, "Location Required" title, "You must be within 200m of Riga Motor Museum". Long description text in slate-300 with preserved newlines, bullet points about how it works, time estimate "45-60 minutes". Bottom: full-width emerald gradient button "Sākt izaicinājumu" (Start Challenge).

**Screen 5 — Active Attempt (Submit Form)**
Back to My Attempts. Header: challenge title + blue "Started" status badge. Timestamps grid: Started date, Submitted "-". Geofence section: rounded card with map (Leaflet-style rectangle), location pin icon, "Location Required — Within 200m of Riga Motor Museum", "Check Location" button, status text "Checking location..." in amber. Below: form with 5 sequential tasks, each in a field wrapper with label (bold, with red asterisk for required), instruction text in slate-400 smaller font, emerald points badge ("10 points" with star icon), then the field-specific input:
- Task 1 "1. solis · Muzeja Pirmsākumi": text input field (dark bg, slate border, emerald focus ring)
- Task 2 "2. solis · Padomju Garāža": 4 radio buttons in a vertical list (Ņikita Hruščovs, Leonīds Brežņevs, Josifs Staļins, Mihails Gorbačovs), each with hover background
- Task 3 "3. solis · Baltijas Automobiļu Mantojums": 4 checkboxes (RAF, Moskvič, Ford-Vairogs, GAZ) with "Select all that apply" hint
- Task 4 "4. solis · Tavs Muzeja Mirklis": 3 photo upload blocks, each with camera icon, "Photo 1/2/3" label, file input styled as emerald button, caption text input below each
- Task 5 "5. solis · Leģenda uz Trases": text input field
Bottom: full-width emerald gradient "Submit Challenge" button (disabled/grayed out if geofence not passed).

**Screen 6 — Attempt Submitted (Waiting)**
Same layout as attempt. Amber "Submitted" status badge. Shows uploaded photos in 2-3 column grid with overlay labels. "Your Answers" section: each answer in a slate card showing field label, answer text, and amber "Pending review" tag. "Edit Answers" link available.

**Screen 7 — Attempt Approved (Result)**
Emerald "Approved" status badge. Large "+95" in emerald 3xl bold with "Points earned" subtitle and "Quiz Score: 45/45" detail. Review info: reviewed date, reviewer name. Photos grid. Answer breakdown: each answer with green "✓ 10/10 pts" or red "✗ 0/10 pts" badge. "Next Steps" section at bottom with border-top: "Congratulations!" message, two buttons — "Browse Challenges" (emerald gradient) and "View Rewards" (slate).

**Screen 8 — Reward Catalogue**
Back to Dashboard. Header: "Rewards" title + count. Right side: "Your Points" label with "20 pts" in emerald bold. 3-column card grid. Each reward card: image placeholder (gift icon on slate bg, h-40), emerald "Active" badge + cost "75 pts" emerald bold, title in white bold, 2-line description, owner name with user icon, stock "50 left" with package icon in emerald, full-width CTA button (emerald gradient if affordable, slate if not). Show two cards: "Motormuzeja Kafejnīcas Kupons" (75 pts, can't afford with 20 pts — slate button) and "Motormuzeja Suvenīru Komplekts" (150 pts, can't afford — slate button).

**Screen 9 — Reward Details**
Back to Rewards. Card layout. Status badge + stock badge. Title "Motormuzeja Kafejnīcas Kupons" in 3xl white bold. Cost "75 pts" emerald 3xl. Info: offered by (user icon), your balance "20 pts" (clock icon). HTML description with paragraphs and bullet list about the café voucher. Bottom: amber text "Nepietiek punktu" (Insufficient points) + "You need 55 more points" in slate text. (When user has enough points: show green "Purchase Reward" button instead.)

**Screen 10 — Order Confirmation**
Back to My Orders. Status badge "Pending" amber. Reward title in 3xl bold. "75 pts" spent emerald 3xl. Grid: ordered date, offered by name. Status Timeline section: vertical list with circular checkmark icons — "Order Placed" with date (emerald, always shown). When approved: add "Order Approved" (blue). When delivered: add "Order Delivered" (emerald). When cancelled: show "Order Cancelled" (red X icon).

**Screen 11 — My Orders**
Back to Dashboard. Title "My Orders" + count. Card list: each order shows status badge, reward title, date, points spent, "View Details" link. Empty state: icon + "No orders yet" + link to Rewards.

Create all screens in sequence showing the complete user journey from login through challenge completion to reward redemption. Use consistent dark theme, emerald/amber accents, and glassmorphism cards throughout. Design for both mobile (single column, smaller text) and desktop (multi-column grids). All text content should be in Latvian as shown above.

**STITCH PROMPT END**

---

## 7. Piezīmes Stitch lietošanai

1. **Ekrānu secība:** Ievieto prompt Stitch un tas ģenerēs prototipa ekrānus secībā
2. **Interaktivitāte:** Stitch automātiski pievienos navigāciju starp ekrāniem
3. **Responsive:** Prompt norāda gan mobile, gan desktop izkārtojumus
4. **Dati:** Visi teksti un skaitļi ir reālistiski, balstoties uz seed datiem
5. **Krāsu sistēma:**
   - Primārā: emerald-500/teal-500 (CTA, pozitīvie statusi)
   - Sekundārā: amber-500/orange-500 (punkti, brīdinājumi, logo)
   - Fons: slate-900 → slate-800 gradient
   - Kartes: slate-800/50 ar white/10 border
   - Teksts: white (virsraksti), slate-300/400 (saturs), slate-500 (hints)
