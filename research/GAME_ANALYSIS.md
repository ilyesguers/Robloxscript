# 🎮 تحليل شامل: +1 Speed Keyboard Escape | Candy & Chocolate

> بحث وتحليل جُمع في **2026-08-18** استعداداً لكتابة سكربت خاص بنا (SpeedPlus).
> المستهدف: **الهاتف + Delta Executor** عبر رابط Raw من GitHub.

---

## 1️⃣ هوية اللعبة

| المعلومة | القيمة |
|---|---|
| الاسم الكامل | `+1 Speed Keyboard Escape | Candy & Chocolate` |
| المطوّر | **SecretVerse Studio** (مجموعة موثّقة) |
| Place ID | **`95082159892680`** |
| Universe ID | `9584852943` |
| تاريخ الإطلاق | 18 يناير 2026 |
| آخر تحديث معروف | 16 أغسطس 2026 (تحديثات أسبوعية "يوم الخميس") |
| عدد المراحل | 17 مرحلة (عالم 1 + عالم 2) |
| الزيارات | +3 مليار — ذروة لاعبين متزامنين +548K |
| الأجهزة | كمبيوتر، موبايل، تابلت، كونسول، VR |

**فكرة اللعبة**: كل خطوة تمشيها = +1 Speed. تبني سرعتك بالمشي (أو التريدميل)،
ثم تقطع مراحل Obby على شكل أزرار كيبورد من حلوى وشوكولاتة. في نهاية كل مرحلة
**Win Block** يمنحك نقاط Wins — العملة الحقيقية للترقية.

---

## 2️⃣ الآليات الداخلية المؤكدة (من تحليل سكربت EtinityHub المفكوك)

فككنا تشفير السكربت الشهير `speedchocolate.lua` (EtinityHub) واستخرجنا:

### الريمونات (Remote Events/Functions) — في `ReplicatedStorage.Remotes`
| الريمون | الاستخدام | مستوى الخطورة |
|---|---|---|
| `Rebirth` | `:FireServer()` — إعادة الولادة (ريبيرث) للحصول على مضاعف | منخفض |
| `ClaimGift` | `:FireServer()` — استلام الهدية اليومية | منخفض |
| `UpdateSpeed` | يُطلق باستمرار لزيادة XP المشي (زرع Speed) — ذُكر في سكربت Noliar HUB | متوسط (إرسال مكثف) |

### خدع الحركة المستخدمة عند المنافسين
- **WalkSpeed Hack**: تحريك `HumanoidRootPart` يدوياً كل Heartbeat بمقدار `MoveDirection * (سرعة/10)` — أسرع من تغيير WalkSpeed وأقل كشفاً.
- **Infinity Jump**: اعتراض `UserInputService.JumpRequest` ثم `Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)`.
- **Noclip**: في `Stepped`، تعطيل `CanCollide = false` لكل الأجزاء عدا `HumanoidRootPart`/`Torso`/`UpperTorso`.
- **Fly**: تحريك حسب اتجاه الكاميرا مع WASD (على الموبايل نحتاج أزرار لمسية بديلة).
- **ESP Chams**: `Highlight` باسم `ESP_Highlight` + **ESP Tracers** عبر `Drawing.new("Line")`.
- **Tween TP**: `TweenService` بسرعة ~270 للسفر السلس نحو لاعب/هدف.

### 🏃 سر الـ Auto Farm عند المنافسين (بدون ريمون!)
السكربت المفكوك **لا يستخدم UpdateSpeed أصلاً** — يستخدم التريدميل:
1. نقل إلى `workspace.SpawnLocation` مع إزاحة `(0, 3, 35)` (موقع التريدميل).
2. محاكاة ضغط أزرار عبر `VirtualInputManager:SendKeyEvent(Enum.KeyCode.W, true)` لمدة 0.5 ثانية، ثم S — وهكذا.
3. اللعبة تحسبها مشياً حقيقياً → Speed يزيد بشكل شرعي 100%.

> 💡 **درس مهم**: المحاكاة بالكيبورد الافتراضي = أبسط وأقل كشفاً من سبام الريمون.

---

## 3️⃣ اقتصاد اللعبة (لماذا نحتاج ميزات معينة)

- **Speed** ← تُبنى بالمشي/التريدميل. تُستهلك للدخول في المراحل.
- **Wins** ← من Win Blocks في نهاية المراحل. تُنفق على: مضاعفات الخطوة، أثر (Trail)، هالة (Aura)، انتقالات.
- **Rebirth** ← يصفّر سرعتك مقابل مضاعف دائم (كلما زاد الريبيرث زاد المضاعف حتى 512x مع Gamepasses).
- **Treadmills** ← درجات: Normal → Diamond → Galaxy (الأفضل يمنح Speed أسرع).
- **Gamepasses** ← مضاعفات (3x حتى 512x) وأشكال (Storm/Chocolate/Candy Aura, Eternal/Ascendant/Transcendant Trail).
- **كوبونات** ← `BYP4SS1` = 15,000 سرعة. + هدية مجموعة SecretVerse وهدية الإعجاب (15K لكل واحدة) + كود Discord الشخصي.

---

## 4️⃣ سكربتات المنافسين الحالية (خريطة الميزات)

| الهب | الميزات الرئيسية |
|---|---|
| **EtinityHub** (فككناه) | WalkSpeed، Inf Jump، Noclip، Fly، ESP، TP للاعبين، Rebirth، ClaimGift، تريدميل |
| **Ajjans Hub** | Auto-win على العالمين، تحييد حمم/فخاخ، Rebirth، ClaimGift، 2x speed، تريدميل، تجهيز تلقائي لأفضل Step/Trail/Aura، Anti-AFK، تحسين أداء |
| **Noliar HUB** | Farm Win (نقل من السبون للـ win zone)، سبام `UpdateSpeed`، سبام `Rebirth`، Noclip أثناء السفر، Fire Rate قابل للضبط |
| **Axon Hub** | Auto XP عبر `UpdateSpeed` بأقصى معدل شرعي، كاش WinBlocks مع **Bypass لـ StreamingEnabled**، TP فوري/ناعم، ESP بأسماء وقيم، Auto Rebirth عند بلوغ الشرط، Auto Equip أفضل Step/Trail، Auto Claim Gift، Auto Revive، جمع عملات/EggRain، ضبط WalkSpeed، Webhook |
| **X3 Draig** | Farm Stages (اختيار 15 مرحلة)، تريدميل تلقائي، WalkSpeed/JumpPower، Noclip/Fly، Server Hop |

### ⚠️ ملاحظات أمان استخلصناها من وصف المنافسين
1. **Win spam بلا ترويسة = فلاغ**: "flagged accounts occur when auto win submits results at inhuman intervals" → نضيف Throttle.
2. **التحديثات يوم الخميس** تكسر السكربتات → نعزل كل أسماء الريمونات/الأجزاء في Config واحد.
3. **StreamingEnabled** → نكاشف WinBlocks ونجبر تحميلها أو نخزّن إحداثياتها.
4. **التحقق سيرفر-سايد** للمراحل → الـ TP السريع للـ win قد لا يُحتسب بدون "قطع" المرحلة فعلياً — يجب اختبار السلوكين (TP مباشر vs مشي سريع).

---

## 4ب. تحديث البحث — 2026-08-18 (إضافات)

- **العالم الثالث موجود**: تحديث "World 3 + Chapter Final" نزل نهاية يونيو 2026 (فعالية أسبوعية). اللعبة الآن 3 عوالم، والـ Stage 12 راهن من عالم 2.
- **التريدميلات بالمضاعفات**: Chocolate مجاني (1x) → Diamond (9x) → Admin (100x).
- **الـ Trail + الـ Aura يتكدسون مضاعفياً** مع الريبيرث — أي "زرع سرعة" لازم يراعي التجهيزات.
- **لوحة الفوز صفراء** ("yellow Wins pad") — متطابقة مع فلتر `New Yeller` في SpeedScript القديم.
- **الكوبونات** (أغسطس 2026): `BYP4SS1` (+15,000 سرعة، يعادل الكود الاجتماعي)، `BBNOWORLD`، `BIGCONCERT` — `CHOCO2026` منتهي.
- **استراتيجية الفوز المثلى**: العب مرحلة واحدة تحت قدرتك وكررها بدل المخاطرة بمرحلة أعلى.
- **Speed يُبنى بأسرع طريقة**: مشي بخطوط مستقيمة على أطول صف + أفضل تريدميل + تجهيز Trail/Aura.

---

## 5️⃣ تصميمنا المقترح: `SpeedPlus.lua`

### مبدأ التشغيل
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/Robloxscript/main/SpeedPlus.lua"))()
```

### المعمارية (ملف واحد، منظم)
```
SpeedPlus.lua
├── 0. Config (أسماء الريمونات/الأجزاء/الثوابت — نقطة الصيانة الوحيدة)
├── 1. Core (خدمات + Notify + Anti-AFK + كاش)
├── 2. UI (واجهة موبايل: زر عائم + قائمة — مستوحاة من Shadow Hub)
├── 3. Speed Engine (تريدميل + محاكاة كيبورد / سبام UpdateSpeed بترويسة)
├── 4. Win Engine (كشف Win Block + نقل سلس + ترويسة)
├── 5. Economy (Rebirth + ClaimGift + كوبونات + تجهيز أفضل Step/Trail)
├── 6. Movement (WalkSpeed/Inf Jump/Noclip/Fly — أزرار للموبايل)
├── 7. ESP (WinBlocks + تريدميلات + لاعبين)
└── 8. HUD (سرعة/وِنس/ريبيرث + حالة المهام)
```

### الميزات المقترحة (بالترتيب المقترح للتنفيذ)
1. **Auto Speed Farm** — تريدميل بمحاكاة كيبورد (وضع آمن) + وضع UpdateSpeed (سريع، بترويسة قابلة للضبط).
2. **Auto Win** — كشف منصة النهاية، نقل سلس، ترويسة لمنع الفلاغ.
3. **Auto Rebirth + Claim Gift + Code (BYP4SS1)**.
4. **حركة**: WalkSpeed، Inf Jump، Noclip، Fly بأزرار موبايل.
5. **ESP** للـ WinBlocks والتريدميلات.
6. **HUD** بحالة حية.
7. **Server Hop** (اختياري لاحقاً).

### معايير الالتزام بالمشروع
- 🎯 مخصص للعبة واحدة فقط (ماب واحد) كما طلبت.
- 📱 تجربة موبايل أولاً: أزرار كبيرة، واجهة بسحب، بدون اختصارات كيبورد.
- 🔌 يعمل عبر رابط Raw مباشر من هذا المستودع.
- 🛡️ ترويسة (rate limiting) لكل ما يُرسل للخادم.

---

## 6️⃣ مصادر

- [Wiki اللعبة (speedkeyboardescape.wiki)](https://speedkeyboardescape.wiki/)
- [صفحة اللعبة على Roblox (Place 95082159892680)](https://www.roblox.com/games/95082159892680/)
- [سكربت EtinityHub (فككنا تشفيره)](https://raw.githubusercontent.com/vanbr0th9-lgtm/speedescape/refs/heads/main/speedchocolate.lua)
- [صفحات rblxscripts / rscripts / scriptblox للسكربتات](https://www.rblxscripts.net/game/1-speed-keyboard-escape-candy-chocolate)
- [دليل bo3.gg للسكربتات](https://bo3.gg/games/articles/plus-1-speed-keyboard-escape-scripts)
- [أداة فك التشفير المحلية: research/decode_xor.py](decode_xor.py)
