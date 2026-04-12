# frozen_string_literal: true

# =============================================================================
# RĪGAS MOTORMUZEJS — TRIVIA IZAICINĀJUMS
# Demo seed: izaicinājums → pabeigšana → atlīdzība → izņemšana
# =============================================================================
#
# Izveido pilnvērtīgu, ģeogrāfiski piesaistītu exploration izaicinājumu
# Rīgas Motormuzejā (Sergeja Eizenšteina iela 6, Mežciems, Rīga) un
# muzeja tematisko atlīdzību, kas demonstrē pilnu produkta ciklu.
#
# Seed dati:
#
#   IZAICINĀJUMS
#   • "Rīgas Motormuzeja Trivia Izaicinājums" (exploration, medium, gold/50 pts)
#   • 5 lauki: teksts → viena izvēle → vairākas izvēles → foto → teksts
#   • Ģeožogs: 200 m rādiuss ap muzeju
#
#   ATLĪDZĪBAS
#   • "Motormuzeja Kafejnīcas Kupons" — 75 pts, 50 gab.
#   • "Motormuzeja Suvenīru Komplekts" — 150 pts, 20 gab.
#
#   LIETOTĀJI & DARBA PLŪSMAS STĀVOKĻI
#   • user@example.com          → sākts mēģinājums (gatavs iesniegt UI)
#   • anna.ozola@example.com    → iesniegts (gaida company apstiprināšanu)
#   • janis.berzins@example.com → apstiprināts (95 pts) → nopircis kuponu → order pending
#
#   company@example.com ir izaicinājuma un atlīdzību veidotājs un recenzents.
#
# Palaist:
#   bin/rails db:seed
#
# =============================================================================
#
# DEMO WALKTHROUGH
#
# ── 1. Atrast & Sākt ──
#
#   Login:  user@example.com / password123
#   Iet uz: Challenges
#   Atrast: "Rīgas Motormuzeja Trivia Izaicinājums" (Exploration · Medium · 50 pts)
#   Darbība: Atvērt detaļas → izlasīt aprakstu un ģeožoga brīdinājumu
#            Sāktais mēģinājums jau gaida → "View My Attempt"
#
# ── 2. Iesniegt atbildes ──
#
#   Mēģinājuma lapā redzami 5 progresīvi uzdevumi ar instrukcijām.
#   Aizpildīt atbildes (atbilžu atslēga zemāk) un augšupielādēt foto.
#
#   ⚠ Ģeožogs: iesniegšanai nepieciešams GPS muzeja tuvumā.
#   Lokālai izstrādei:
#     • Chrome DevTools → Sensors → Override location: 56.9706, 24.2277
#     • Vai rails console: Challenge.find_by(title: "Rīgas Motormuzeja...").update(location: nil)
#
#   Nospiest "Submit Challenge" → statuss mainās uz "Submitted"
#
# ── 3. Pārskatīt & Apstiprināt ──
#
#   Login:  company@example.com / password123
#   Iet uz: Admin → Challenges → "Rīgas Motormuzeja…" → Attempts tab
#           Vai tieši atvērt Annas Ozolas iesniegto mēģinājumu
#   Redz:   Atbilžu sadalījums ar zaļo ✓ / sarkano ✗ pie katra lauka
#   Darbība: Nospiest "Approve" → apstiprināt modālajā logā
#            → Statuss kļūst "Approved", punkti piešķirti
#
# ── 4. Pārbaudīt punktus ──
#
#   Login:  janis.berzins@example.com / password123
#   Iet uz: Profile → reward_points rāda nopelnīto rezultātu
#   Iet uz: My Attempts → apstiprinātais mēģinājums rāda punktu sadalījumu
#           (Jautājumi: 45/45 + Gold bāze: 50 = kopā 95 pts)
#
# ── 5. Atlīdzību katalogs & Izņemšana ──
#
#   Joprojām kā janis.berzins@ (vai pēc anna.ozola@ apstiprināšanas):
#   Iet uz: Rewards → atrast "Motormuzeja Kafejnīcas Kupons" (75 pts)
#   Darbība: Atvērt detaļas → nospiest "Purchase Reward"
#            → Pārvirza uz Order lapu (statuss: Pending)
#            → Punktu atlikums samazinās par 75
#
#   Piezīme: janis.berzins@ jau ir seeded pending order šai atlīdzībai
#            (redzams My Orders un Admin → Orders).
#
# ── 6. Izpildīt pasūtījumu (admin) ──
#
#   Login:  company@example.com / password123
#   Iet uz: Admin → Orders → atrast Jāņa Bērziņa pending order
#   Darbība: Nospiest "Approve" → tad "Deliver"
#            → Order statusa laika līnija: Pending → Approved → Delivered
#
# ── Atbilžu atslēga ──
#
#   1. solis "Muzeja Pirmsākumi"          → 1989
#   2. solis "Padomju Garāža"            → Leonīds Brežņevs
#   3. solis "Baltijas Automobiļu Mantojums" → RAF (Rīgas Autobusu Fabrika) + Ford-Vairogs
#   4. solis "Tavs Muzeja Mirklis"       → jebkurš foto (0 pts, obligāts)
#   5. solis "Leģenda uz Trases"         → Auto Union
#
#   Visas pareizas = 45 lauku pts + 50 gold bāze = kopā 95
#
# =============================================================================

return unless Rails.env.development?

puts "Seeding Rīgas Motormuzeja demo..."

# ---------------------------------------------------------------------------
# Konstantes — stabili UUID, lai atkārtotas seed nepazaudētu atbildes
# ---------------------------------------------------------------------------
MOTOR_MUSEUM_TITLE      = "Rīgas Motormuzeja Trivia Izaicinājums"
MOTOR_MUSEUM_OLD_TITLE  = "Riga Motor Museum Trivia Quest"
MOTOR_MUSEUM_REWARD_1   = "Motormuzeja Kafejnīcas Kupons"
MOTOR_MUSEUM_REWARD_2   = "Motormuzeja Suvenīru Komplekts"
MOTOR_MUSEUM_OLD_REWARD = "Motor Museum Café Voucher"

FIELD_ORIGINS = "f10a0001-rmm1-4000-a000-000000000001"
FIELD_SOVIET  = "f10a0002-rmm2-4000-a000-000000000002"
FIELD_BALTIC  = "f10a0003-rmm3-4000-a000-000000000003"
FIELD_PHOTO   = "f10a0004-rmm4-4000-a000-000000000004"
FIELD_LEGEND  = "f10a0005-rmm5-4000-a000-000000000005"

# ---------------------------------------------------------------------------
# Palīgmetodes
# ---------------------------------------------------------------------------
def motor_museum_photo_upload
  path = Rails.root.join("spec/fixtures/files/test.png")
  return nil unless File.exist?(path)

  tmp = Tempfile.new(["motor_museum_proof", ".png"])
  tmp.binmode
  tmp.write(File.binread(path))
  tmp.rewind
  ActionDispatch::Http::UploadedFile.new(tempfile: tmp, filename: "muzeja_foto.png", type: "image/png")
end

# ---------------------------------------------------------------------------
# Atsauces dati
# ---------------------------------------------------------------------------
company_user = User.find_by(email: "company@example.com")
general_role = Role.find_by(name: "general_user")
exploration  = ChallengeType.find_by(code: "exploration")
medium       = DifficultyLevel.find_by(code: "medium")
gold         = AwardPointLevel.find_by(code: "gold")
location     = Location.find_by(name: "Riga Motor Museum")

unless company_user && general_role && exploration && medium && gold && location
  puts "  [motormuzejs] Izlaižam — trūkst priekšnosacījumu datu."
  return
end

# ---------------------------------------------------------------------------
# Notīrām iepriekšējo angļu versiju, ja tāda eksistē
# ---------------------------------------------------------------------------
old_challenge = Challenge.find_by(title: MOTOR_MUSEUM_OLD_TITLE)
if old_challenge
  ChallengeAttempt.where(challenge: old_challenge).destroy_all
  PointsHistory.where(challenge: old_challenge).delete_all
  old_challenge.destroy!
  puts "  Noņemts iepriekšējais izaicinājums: #{MOTOR_MUSEUM_OLD_TITLE}"
end

old_reward = Reward.find_by(title: MOTOR_MUSEUM_OLD_REWARD)
if old_reward
  old_order_ids = Order.where(reward: old_reward).pluck(:id)
  PointsHistory.where(order_id: old_order_ids).delete_all if old_order_ids.any?
  Order.where(id: old_order_ids).delete_all if old_order_ids.any?
  old_reward.destroy!
  puts "  Noņemta iepriekšējā atlīdzība: #{MOTOR_MUSEUM_OLD_REWARD}"
end

# ---------------------------------------------------------------------------
# Demo dalībnieki
# ---------------------------------------------------------------------------
demo_accounts = {
  "anna.ozola@example.com"    => { first: "Anna",  last: "Ozola"   },
  "janis.berzins@example.com" => { first: "Jānis", last: "Bērziņš" }
}

demo_accounts.each do |email, names|
  next if User.exists?(email: email)

  User.create!(
    email: email,
    password: "password123",
    password_confirmation: "password123",
    first_name: names[:first],
    last_name: names[:last],
    admin: false,
    role: general_role
  )
  puts "  Izveidots #{email} / password123"
end

regular_user   = User.find_by(email: "user@example.com")
submitted_user = User.find_by!(email: "anna.ozola@example.com")
approved_user  = User.find_by!(email: "janis.berzins@example.com")

# ---------------------------------------------------------------------------
# Izaicinājuma lauki — piecu soļu vadīta muzeja pieredze
# ---------------------------------------------------------------------------
fields_config = [
  # 1. solis — Iesildīšanās pie ieejas
  {
    "id"             => FIELD_ORIGINS,
    "type"           => "text_input",
    "label"          => "1. solis · Muzeja Pirmsākumi",
    "instructions"   => "Atrodi informāciju par muzeja dibināšanu pie galvenās ieejas. Kurā gadā tika dibināts Rīgas Motormuzejs? (Mājiens: tas bija tajā pašā gadā, kad krita Berlīnes mūris.)",
    "required"       => true,
    "position"       => 0,
    "points"         => 10,
    "correct_answer" => "1989",
    "case_sensitive" => false
  },

  # 2. solis — Pirmais stāvs, PSRS vadītāju automobiļi
  {
    "id"             => FIELD_SOVIET,
    "type"           => "single_choice",
    "label"          => "2. solis · Padomju Garāža",
    "instructions"   => "Dodies uz pirmo stāvu, kur atrodas PSRS valsts vadītāju automobiļu ekspozīcija. Viena līdera personīgā kolekcija ir ekspozīcijas centrālais elements — viņa bruņotās limuzīnes un luksusa automobiļi dominē zālē. Kurš tas ir?",
    "required"       => true,
    "position"       => 1,
    "points"         => 10,
    "options"        => [
      "Ņikita Hruščovs",
      "Leonīds Brežņevs",
      "Josifs Staļins",
      "Mihails Gorbačovs"
    ],
    "correct_answer" => "Leonīds Brežņevs"
  },

  # 3. solis — Zemākais stāvs, Latvijas automobiļu vēsture
  {
    "id"              => FIELD_BALTIC,
    "type"            => "multiple_choice",
    "label"           => "3. solis · Baltijas Automobiļu Mantojums",
    "instructions"    => "Pirmajā stāvā atrodas Latvijas automobiļu vēstures ekspozīcija. Uzmanīgi aplūko eksponātu uzrakstus. Kuri no šiem automobiļiem tiešām tika ražoti Latvijā? Atzīmē visus pareizos.",
    "required"        => true,
    "position"        => 2,
    "points"          => 15,
    "options"         => [
      "RAF (Rīgas Autobusu Fabrika)",
      "Moskvič",
      "Ford-Vairogs",
      "GAZ (Gorkija)"
    ],
    "correct_answers" => ["RAF (Rīgas Autobusu Fabrika)", "Ford-Vairogs"]
  },

  # 4. solis — Foto pierādījums
  {
    "id"              => FIELD_PHOTO,
    "type"            => "photo_upload",
    "label"           => "4. solis · Tavs Muzeja Mirklis",
    "instructions"    => "Nobildē transportlīdzekli vai eksponātu, kas tevi visvairāk iespaidoja. Mēģini iekļaut kadrā arī eksponāta uzrakstu.",
    "required"        => true,
    "position"        => 3,
    "max_photos"      => 3,
    "require_caption" => true
  },

  # 5. solis — Autosporta sadaļa, sudraba sacīkšu auto
  {
    "id"             => FIELD_LEGEND,
    "type"           => "text_input",
    "label"          => "5. solis · Leģenda uz Trases",
    "instructions"   => "Autosporta sadaļā atradīsi pārsteidzošu sudraba krāsas 1930. gadu Grand Prix sacīkšu auto repliku, kuras oriģinālu no metāllūžņiem izglāba latviešu entuziasts Viktors Kulbergs. Kā sauc ražotāju? (Divi vārdi.)",
    "required"       => true,
    "position"       => 4,
    "points"         => 10,
    "correct_answer" => "Auto Union",
    "case_sensitive" => false
  }
]

# ---------------------------------------------------------------------------
# Izaicinājuma apraksts — atveidots ar whitespace-pre-wrap show skatā
# ---------------------------------------------------------------------------
description = <<~DESC
  Iekāp lielākajā automobiļu muzejā Baltijā un pārbaudi savas zināšanas!

  Šis vadītais trivia izaicinājums aizvedīs tevi cauri trim muzeja stāviem — no Latvijas paša Ford-Vairogs montāžas līnijas un RAF mikroautobusiem, cauri PSRS līderu bruņotajām limuzīnēm, līdz leģendārajiem sudraba sacīkšu automobiļiem, kas kādreiz dominēja Eiropas Grand Prix trasēs.

  Kā tas darbojas:
  • Atbildi uz pieciem jautājumiem, pētot ekspozīcijas
  • Nobildē savu iecienītāko eksponātu
  • Iesniedz atbildes — tās tiks pārskatītas
  • Par katru pareizu atbildi saņem punktus, ko vari apmainīt pret balvām

  Tev jāatrodas muzejā, lai iesniegtu atbildes (GPS pārbaude #{location.radius_meters} m rādiusā ap ēku).

  Ieplāno 45–60 minūtes. Sāc pie galvenās ieejas un virties uz augšu.
DESC

# ---------------------------------------------------------------------------
# Izaicinājuma upsert
# ---------------------------------------------------------------------------
challenge = Challenge.find_or_initialize_by(title: MOTOR_MUSEUM_TITLE)
challenge.assign_attributes(
  creator_user:      company_user,
  location:          location,
  challenge_type:    exploration,
  difficulty_level:  medium,
  award_point_level: gold,
  description:       description.strip,
  is_active:         true,
  fields_config:     fields_config
)
challenge.save!
puts "  Izaicinājums \"#{MOTOR_MUSEUM_TITLE}\" (id=#{challenge.id}) — exploration, medium, gold (#{gold.points} bāzes pts)"

# ---------------------------------------------------------------------------
# Atlīdzība #1 — Kafejnīcas kupons (pieejams pēc viena izaicinājuma)
# ---------------------------------------------------------------------------
reward_1_desc = <<~HTML
  <p>Apbalvo sevi pēc Trivia Izaicinājuma! Šis kupons nodrošina bezmaksas karstu dzērienu un konditorejas izstrādājumu Motormuzeja kafejnīcā.</p>
  <ul>
    <li>Derīgs vienas vizītes laikā izsniegšanas dienā</li>
    <li>Uzrādi pasūtījuma apstiprinājumu pie kases</li>
    <li>Ietver jebkuru kafiju, tēju vai karsto šokolādi, kā arī vienu konditorejas izstrādājumu</li>
  </ul>
  <p><em>Piedāvā Rīgas Motormuzeja apmeklētāju pieredzes komanda.</em></p>
HTML

reward_cafe = Reward.find_or_initialize_by(title: MOTOR_MUSEUM_REWARD_1)
reward_cafe.assign_attributes(
  owner_user:     company_user,
  description:    reward_1_desc.strip,
  cost_points:    75,
  is_active:      true,
  stock_quantity: 50
)
reward_cafe.save!
puts "  Atlīdzība \"#{MOTOR_MUSEUM_REWARD_1}\" (id=#{reward_cafe.id}) — 75 pts, 50 gab."

# ---------------------------------------------------------------------------
# Atlīdzība #2 — Suvenīru komplekts (premium, prasa vairāk punktu)
# ---------------------------------------------------------------------------
reward_2_desc = <<~HTML
  <p>Ekskluzīvs Motormuzeja suvenīru komplekts īstiem automobiļu entuziastiem.</p>
  <ul>
    <li>Metāla atslēgu piekariņš ar Auto Union repliku</li>
    <li>Motormuzeja magnēts ar retro dizainu</li>
    <li>Kolekcijas pastkarte ar Brezhnev limuzīnes attēlu</li>
  </ul>
  <p>Izņemams muzeja suvenīru veikalā, uzrādot pasūtījuma apstiprinājumu.</p>
  <p><em>Ierobežots daudzums — tikai pirmajiem 20 dalībniekiem.</em></p>
HTML

reward_souvenir = Reward.find_or_initialize_by(title: MOTOR_MUSEUM_REWARD_2)
reward_souvenir.assign_attributes(
  owner_user:     company_user,
  description:    reward_2_desc.strip,
  cost_points:    150,
  is_active:      true,
  stock_quantity: 20
)
reward_souvenir.save!
puts "  Atlīdzība \"#{MOTOR_MUSEUM_REWARD_2}\" (id=#{reward_souvenir.id}) — 150 pts, 20 gab."

# ---------------------------------------------------------------------------
# Notīrām iepriekšējos demo mēģinājumus un pasūtījumus (idempotence)
# ---------------------------------------------------------------------------
museum_rewards = [reward_cafe, reward_souvenir]
demo_users = [regular_user, submitted_user, approved_user].compact
demo_users.each do |user|
  museum_rewards.each do |reward|
    demo_order_ids = Order.where(user: user, reward: reward).pluck(:id)
    PointsHistory.where(user: user, order_id: demo_order_ids).delete_all if demo_order_ids.any?
    Order.where(id: demo_order_ids).delete_all if demo_order_ids.any?
  end

  PointsHistory.where(user: user, challenge: challenge, reason_code: PointsHistory::REASON_CHALLENGE_AWARD).delete_all
  ChallengeAttempt.where(user: user, challenge: challenge).destroy_all

  user.update_column(:reward_points, [user.points_history.sum(:delta_points), 0].max)
end
reward_cafe.update_column(:stock_quantity, 50)
reward_souvenir.update_column(:stock_quantity, 20)

# ---------------------------------------------------------------------------
# Pareizo atbilžu kopa (izmanto abos seeded iesniegumos)
# ---------------------------------------------------------------------------
correct_answers = {
  FIELD_ORIGINS => "1989",
  FIELD_SOVIET  => "Leonīds Brežņevs",
  FIELD_BALTIC  => ["RAF (Rīgas Autobusu Fabrika)", "Ford-Vairogs"],
  FIELD_LEGEND  => "Auto Union"
}

started_status = AttemptStatus.find_by!(code: "started")
lat = location.latitude.to_f
lng = location.longitude.to_f

# ---------------------------------------------------------------------------
# 1) user@example.com — SĀKTS (gatavs iesniegt UI)
# ---------------------------------------------------------------------------
if regular_user
  ChallengeAttempt.create!(
    user: regular_user,
    challenge: challenge,
    attempt_status: started_status,
    started_at: 30.minutes.ago
  )
  puts "  → user@example.com: sākts (atver UI, lai iesniegtu)"
end

# ---------------------------------------------------------------------------
# 2) anna.ozola@example.com — IESNIEGTS (gaida apstiprināšanu)
# ---------------------------------------------------------------------------
photo = motor_museum_photo_upload
if photo
  attempt = ChallengeAttempt.create!(
    user: submitted_user,
    challenge: challenge,
    attempt_status: started_status,
    started_at: 3.hours.ago
  )

  form = Attempts::SubmitActions::Form.new(attempt)
  form.update(
    user_latitude: lat,
    user_longitude: lng,
    answers: correct_answers,
    photos: { FIELD_PHOTO => [photo] },
    photo_captions: { FIELD_PHOTO => { "1" => "Sudraba Auto Union replika — elpu aizraujošs skats klātienē!" } }
  )

  if attempt.reload.submitted?
    puts "  → anna.ozola@example.com: iesniegts (visas pareizas, gaida apstiprināšanu)"
  else
    puts "  ✗ anna.ozola iesniegšana neizdevās: #{form.errors.full_messages.join(', ')}"
  end
else
  puts "  ⚠ Izlaižam iesniegtos/apstiprinātos mēģinājumus — nav spec/fixtures/files/test.png"
end

# ---------------------------------------------------------------------------
# 3) janis.berzins@example.com — APSTIPRINĀTS → ATLĪDZĪBA NOPIRKTA
#    Pilns ceļš: sākt → iesniegt → apstiprināt (95 pts) → nopirkt kuponu (75 pts)
# ---------------------------------------------------------------------------
photo = motor_museum_photo_upload
if photo
  attempt = ChallengeAttempt.create!(
    user: approved_user,
    challenge: challenge,
    attempt_status: started_status,
    started_at: 1.day.ago
  )

  form = Attempts::SubmitActions::Form.new(attempt)
  form.update(
    user_latitude: lat,
    user_longitude: lng,
    answers: correct_answers,
    photos: { FIELD_PHOTO => [photo] },
    photo_captions: { FIELD_PHOTO => { "1" => "Brežņeva bruņotais ZIL — iespaidīgs smagums!" } }
  )

  unless attempt.reload.submitted?
    puts "  ✗ janis.berzins iesniegšana neizdevās: #{form.errors.full_messages.join(', ')}"
  else
    approve = Attempts::ApproveActions::Form.new(attempt)
    if approve.create(reviewer: company_user) && attempt.reload.approved?
      puts "  → janis.berzins@example.com: apstiprināts (#{attempt.score_awarded} pts piešķirti)"

      purchase = Rewards::Purchase.new(user: approved_user.reload, reward: reward_cafe)
      result = purchase.call

      if result.success?
        puts "  → janis.berzins@example.com: nopircis \"#{MOTOR_MUSEUM_REWARD_1}\" " \
             "(#{reward_cafe.cost_points} pts tērēti, atlikums: #{approved_user.reload.reward_points} pts, " \
             "pasūtījums ##{result.order.id} gaida izpildi)"
      else
        puts "  ✗ janis.berzins atlīdzības pirkšana neizdevās: #{result.errors.join(', ')}"
      end
    else
      puts "  ✗ janis.berzins apstiprināšana neizdevās: #{approve.errors.full_messages.join(', ')}"
    end
  end
end

puts "  Rīgas Motormuzeja demo pabeigts."
