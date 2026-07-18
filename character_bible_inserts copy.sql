INSERT INTO "Character" ("id", "name", "category", "description", "promptConsistency", "characterBible", "positivePrompt", "negativePrompt", "masterPrompt") VALUES (gen_random_uuid(),
'Si Piko',
'Animal',
'An orange chubby tabby cat that loves eating snacks.',
'A fat orange tabby cat, cute cartoon style, large expressive eyes.',
'{
  "identity": "Si Piko is a plump orange tabby cat mascot built for warmth and comedy, a snack loving companion character whose design communicates softness, roundness, and gentle gluttony. The character reads instantly at any scale thanks to a simple rounded silhouette and a consistent orange and cream palette.",
  "silhouette": "One continuous rounded outline, a large round head sitting almost directly on a wide oval body with no visible neck, four short stubby legs, thick tapering tail curling to one side, no sharp angles anywhere.",
  "body_proportions": "Head to body ratio near 1 to 1.2, body width roughly equal to body height, legs about one fifth of total body height.",
  "body_language": "Relaxed and food motivated, leans slightly forward as if sniffing for food, tail moves in slow lazy curves when content.",
  "anatomy": "Simplified quadruped feline anatomy, shortened spine, exaggerated round rib cage and belly, soft continuous curves with no visible musculature.",
  "posture": "Sits low to the ground due to short legs and a heavy round belly, spine gently curved, head tilted slightly downward and forward.",
  "head_and_face": {
    "head_proportions": "Very large round head, nearly spherical, slightly flattened lower jaw area for cheeks.",
    "face_proportions": "Wide set eyes at roughly one third of face width, small triangular nose centered low, cheeks are the widest point of the face.",
    "forehead": "Broad and rounded with two faint darker orange tabby stripes running from between the ears toward the eyebrow area.",
    "cheeks": "Very full and rounded, puffed outward on both sides to imply constant chewing and snack storage.",
    "jaw": "Soft and rounded with no visible jawline, blends into the cheeks and chin.",
    "chin": "Small and rounded, tucked beneath the mouth, cream fur tone matching the belly.",
    "ears": "Small triangular ears with rounded tips set high and slightly outward, inner ear lined with pale pink fur, outer ear matches the darker tabby tone."
  },
  "eyes": {
    "shape": "Large wide oval leaning round, upper lid arched high for a perpetually delighted expression.",
    "iris": "Warm amber gold iris filling most of the visible eye.",
    "iris_gradient": "Radial gradient from a light honey yellow center outward to a deeper amber brown rim.",
    "iris_texture": "Fine radiating linework suggesting soft light catching facets, kept subtle for a clean vector friendly look.",
    "pupils": "Large round black pupils that narrow to vertical ovals only in bright light or alert moments.",
    "reflections_catchlights": "Two catchlights per eye, one large soft highlight upper left, one small secondary highlight lower right.",
    "eyelashes": "No individual lashes, the upper lid line is slightly thickened and dark to imply lash density.",
    "eyebrows": "No true eyebrows, expression carried by eyelid shape and the small forehead tabby stripes."
  },
  "nose_mouth": {
    "nose": "Small pink triangular cat nose with rounded corners centered above the mouth.",
    "mouth": "Simple curved w shaped feline mouth line beneath the nose, widening into a smile at the sides.",
    "lips": "No separate visible lips, mouth defined by the curved line and shading beneath the nose.",
    "smile": "Default is a soft closed contented smile, widening into an open smile when food is present.",
    "teeth": "Two small rounded upper fangs visible only in wide open smiles, otherwise hidden.",
    "tongue": "Small rounded pink tongue visible only in wide open happy or eating expressions."
  },
  "hair_or_fur": {
    "type": "Short dense plush cartoon fur rendered as smooth soft shaded volume rather than individual strands.",
    "hairstyle": "Not applicable, fur only, no head hair.",
    "fur_density": "High density, soft plush rounded look with no visible skin anywhere.",
    "fur_softness": "Very soft and slightly fluffy, especially around cheeks, chest, and tail tip.",
    "fur_direction": "Flows outward from the spine toward the belly and outward from the face center toward the cheeks.",
    "fur_layering": "Two tone layering, base orange coat with a lighter cream underlayer on belly, chest, muzzle, chin, and paws.",
    "fur_color_transitions": "Soft feathered edge where orange meets cream, tabby stripes fade slightly at their edges rather than having a hard outline.",
    "whiskers": "Six long white whiskers per side, three angled upward above the mouth, three angled slightly downward below, always symmetrical."
  },
  "limbs_and_extremities": {
    "tail": "Long thick tail with alternating orange and darker brown tabby rings, rounded soft tip, usually curled into a gentle question mark shape at rest.",
    "paws_or_hands": "Small round paws with a cream colored top, pink paw pads visible on the bottom only in action poses.",
    "claws": "Never visible, always retracted, consistent with the friendly non threatening design.",
    "skin_or_fur_base": "Base fur color functions as the skin layer, no bare skin is ever shown.",
    "skin_tone": "Not applicable, fully furred, base tone matches the primary orange palette color.",
    "skin_texture": "Not applicable, texture expressed entirely through fur shading and softness."
  },
  "wardrobe": {
    "materials": "Bare tabby coat is the primary presentation, any accessory uses soft matte fabric or lightly glossy ceramic.",
    "clothing_items": ["None by default, the bare tabby coat is the preferred presentation"],
    "accessories": ["Small red woven collar with a round gold bell worn snug at the base of the neck"],
    "shoes": "None, barefoot with visible paw pads in dynamic poses.",
    "equipment": "None.",
    "props": ["Small ceramic snack bowl", "A fish shaped cracker or dumpling snack held in the paws or mouth for eating themed art"]
  },
  "color_palette": {
    "primary": "#F2A03D warm tabby orange base coat",
    "secondary": "#C97A2B deep tabby stripe tone",
    "accent": "#FFF3D9 cream belly muzzle chin and paw tone",
    "eyes": "#F5C24B amber gold iris",
    "skin_or_fur_base": "#F2A03D matches primary coat",
    "detail_hex_list": ["#F2A03D", "#C97A2B", "#FFF3D9", "#F5C24B", "#8B5A2B", "#F2A6C4", "#D6392E"]
  },
  "rendering": {
    "style": "Cute cartoon mascot style with soft cel shading.",
    "illustration_style": "Clean vector friendly outlines with two to three shading tones per fur area, no painterly texture, no photoreal fur strands.",
    "lighting": "Soft single key light from upper left, gentle ambient fill, rounded soft edged shadows.",
    "composition": "Centered single character mascot framing, reads clearly in full body or head and shoulders crop.",
    "camera": "Slight low angle three quarter view for a friendly read, straight on front view for icon use.",
    "framing": "Full body framing with generous padding around the silhouette for sticker and icon extraction.",
    "background_compatibility": "Transparent or flat pastel backgrounds, works on cream, mint, and light blue backdrops.",
    "environment_compatibility": "Cozy indoor kitchen, snack shop counters, sunny windowsills, picnic blankets."
  },
  "poses": {
    "standing": "Four legged stance, weight even, tail curled gently to one side, head tilted slightly down as if sniffing for food.",
    "idle": "Seated loaf position, front paws tucked under the chest, tail wrapped around the body, eyes half closed in contentment.",
    "walking": "Slow deliberate step cycle, belly swaying slightly, tail swishing in a lazy arc opposite the front leg motion.",
    "running": "Body stretched slightly longer, ears pinned back, tail streaming behind, silhouette stays rounded and cute rather than realistic.",
    "action": "Leaping toward a snack with front paws outstretched and mouth open in an excited smile.",
    "gesture_language": "Tail position is the primary emotion signal, high curled tail for excitement, low flat tail for disappointment, puffed tail for surprise."
  },
  "facial_expressions": {
    "default": "Soft closed mouth contented smile with relaxed half lidded eyes.",
    "happy": "Wide open eyes, big open mouth smile showing the two small fangs, cheeks pushed up higher.",
    "surprised": "Eyes wide and fully round, pupils shrunk small, ears pointed straight up, mouth small and rounded.",
    "determined_or_focused": "Eyes narrowed slightly, forehead stripes drawn closer together, mouth a small flat line, usually leaning toward a snack.",
    "sad_or_pouting": "Eyes larger with lowered outer corners, mouth curved into a small downward frown, ears drooped slightly."
  },
  "consistency_rules": {
    "always_identical": ["Orange and cream tabby coloring", "Round chubby body silhouette", "Amber gold eye color", "Small triangular ears with pink inner fur", "Ringed tail pattern"],
    "never_change": ["Species must remain a cat", "Body type must remain chubby and round, never slimmed down", "Must never gain human hands, human clothing sets, or a bipedal humanoid body"],
    "mandatory_colors": ["#F2A03D primary coat", "#C97A2B stripe tone", "#FFF3D9 belly and muzzle", "#F5C24B eye color"],
    "mandatory_proportions": ["Head to body ratio near 1 to 1.2", "Legs no longer than one fifth of body height", "Eyes at roughly one third of face width"],
    "mandatory_accessories": ["Red collar with round gold bell whenever an accessory is shown"],
    "mandatory_clothing": ["None, bare tabby coat is the default and preferred state"],
    "mandatory_rendering_style": "Clean cel shaded cartoon mascot style with soft rounded shading, never photorealistic fur rendering.",
    "mandatory_silhouette": "Single continuous rounded outline, round head directly on oval body, no visible neck, four short legs, curled ringed tail.",
    "common_ai_mistakes": ["Body drawn too slim or athletic instead of round and chubby", "Rendering a realistic short haired domestic cat instead of the stylized coat", "Losing the tabby stripe pattern on the forehead and tail", "Adding human clothing or standing the character upright on two legs", "Shifting eye color to green or blue instead of amber gold"],
    "identity_drift_prevention": ["Always restate the orange tabby chubby cat description before generating a new pose or expression", "Always include the amber gold eye color explicitly in every prompt", "Always specify the ringed tail pattern to avoid a plain solid tail"],
    "cross_model_consistency": ["Lead every prompt with the fixed description a fat orange tabby cat cute cartoon style large expressive eyes before adding scene detail", "Keep the same hex codes in every prompt regardless of image model", "Avoid open ended style words like realistic or detailed fur that push different models toward inconsistent rendering"]
  }
}'::jsonb,
'A fat orange tabby cat mascot character named Si Piko, plump round chubby body, large round head with full puffed cheeks, big expressive amber gold eyes with soft radial gradient and two catchlights, small pink triangular nose, soft closed mouth smile, short stubby legs, thick tail with alternating orange and brown tabby rings curled to one side, cream colored belly muzzle chin and paw fur, small triangular ears with pale pink inner fur, six long white whiskers, wearing a small red woven collar with a round gold bell, sitting beside a ceramic snack bowl, clean cel shaded cartoon mascot style, soft rounded vector friendly linework, soft single key light from upper left, flat pastel cream background, centered full body composition, high consistency character design',
'realistic fur texture, photorealistic cat, slim or athletic body, long legs, human clothing, bipedal human body, human hands, sharp angular features, green or blue eyes, missing tabby stripes, missing whiskers, missing collar bell, extra limbs, extra tails, distorted proportions, dark or muted color palette, harsh dramatic lighting, blurry, low detail, text, watermark, signature',
'CHARACTER BIBLE: SI PIKO. Species and Archetype: a plump orange tabby cat mascot, the snack obsessed companion character of the platform. Core Silhouette: one continuous rounded outline formed by a large round head merged almost directly into a wide oval body, four short stubby legs, and a thick curled ringed tail, no sharp angles anywhere. Proportions: head to body ratio approximately 1 to 1.2, eyes occupying roughly one third of total face width, legs no longer than one fifth of total body height. Head and Face: broad rounded forehead with two faint darker tabby stripes, extremely full rounded cheeks as the widest point of the face, soft rounded jaw and chin with no hard edges, small triangular ears set high with pale pink inner fur. Eyes: large wide amber gold irises with a radial gradient from light honey center to deep amber brown rim, large round black pupils, two catchlights per eye, no individual eyelashes, expression carried through eyelid shape. Nose and Mouth: small pink triangular nose, simple curved feline mouth line with a default soft closed smile, two small rounded fangs visible only in wide open happy expressions, small pink tongue visible only when eating. Coat: short dense plush cartoon fur rendered in soft cel shaded volumes, primary coat color hex F2A03D with deep tabby stripe tone hex C97A2B, cream underlayer hex FFF3D9 on belly muzzle chin and paws, soft feathered transition where the two tones meet, six long white whiskers arranged symmetrically. Tail: long and thick with alternating orange and brown tabby rings and a soft rounded tip, default resting position is a gentle curl to one side. Wardrobe: no clothing by default to preserve the classic tabby silhouette, optional small red woven collar with a round gold bell as the only mandatory accessory when accessories are shown. Rendering Style: clean vector friendly cel shading with two to three tonal layers per fur region, soft single key light from the upper left, gentle ambient fill, rounded soft edged shadows, no photorealistic fur strand rendering. Composition: centered full body mascot framing with generous padding, works equally in full body or head and shoulders crop, transparent or flat pastel backgrounds preferred. Consistency Mandate: every generation must preserve the orange and cream tabby coloring, the round chubby silhouette, the amber gold eyes, the ringed tail pattern, and the small triangular pink lined ears exactly as specified, must never become slim, athletic, bipedal, human clothed, or rendered in a photorealistic fur style, and must always restate this coat color, eye color, and body proportion description at the start of every new prompt to prevent identity drift across GPT Image, Imagen, Flux, Midjourney, Stable Diffusion, Recraft, and Ideogram.'
);

INSERT INTO "Character" ("id", "name", "category", "description", "promptConsistency", "characterBible", "positivePrompt", "negativePrompt", "masterPrompt") VALUES (gen_random_uuid(),
'Bubu si Beruang',
'Animal',
'A small brown bear that always carries a jar of honey.',
'A small brown bear holding a honey jar, cute, stylized 3D animation.',
'{
  "identity": "Bubu si Beruang is a small round bodied brown bear cub character defined by warmth, gentleness, and an unbreakable attachment to a honey jar he carries everywhere. Designed as a soft stylized 3D style mascot that reads as cuddly and approachable at any scale.",
  "silhouette": "Compact rounded silhouette, big round head, short round body, short stubby limbs, small round ears, no sharp edges, the honey jar forms a secondary recognizable silhouette element in his paws.",
  "body_proportions": "Head to body ratio near 1 to 1.3, small child like proportions, short thick limbs about one quarter of total body height, round belly the widest part of the torso.",
  "body_language": "Gentle, slow moving, affectionate, tends to hug the honey jar close to the chest when idle.",
  "anatomy": "Simplified stylized bear anatomy, soft rounded shoulders and hips, no visible musculature, thick paws, small rounded muzzle.",
  "posture": "Slightly hunched forward posture cradling the honey jar in both front paws, feet planted wide for stability.",
  "head_and_face": {
    "head_proportions": "Large round head, nearly spherical, with a shorter rounded muzzle projecting forward.",
    "face_proportions": "Eyes set at the midline of the face at moderate width, muzzle occupies the lower third of the face, ears sit at the top corners of the head.",
    "forehead": "Smooth rounded forehead with no markings, slightly lighter brown tone than the rest of the head.",
    "cheeks": "Soft rounded cheeks, moderately full but less exaggerated than the muzzle.",
    "jaw": "Rounded soft jaw blending into the muzzle with no hard edge.",
    "chin": "Small rounded chin at the base of the muzzle, cream colored fur.",
    "ears": "Small round ears set high on the head, slightly forward facing, inner ear lined with pale cream fur."
  },
  "eyes": {
    "shape": "Medium round eyes, gentle and slightly downturned at the outer corner for a kind expression.",
    "iris": "Deep warm brown iris.",
    "iris_gradient": "Subtle gradient from a lighter caramel brown center to a darker chocolate brown rim.",
    "iris_texture": "Minimal soft radiating texture, kept simple for a clean stylized 3D look.",
    "pupils": "Large round black pupils that dominate most of the iris for a soft childlike gaze.",
    "reflections_catchlights": "One large soft catchlight upper left in each eye for a warm friendly shine.",
    "eyelashes": "No visible individual lashes, upper lid rendered with a slightly darker soft shadow line.",
    "eyebrows": "No true eyebrows, gentle brow ridge shading above each eye conveys warmth."
  },
  "nose_mouth": {
    "nose": "Large rounded black nose at the tip of the muzzle, slightly glossy highlight.",
    "mouth": "Simple curved smile line beneath the nose, gentle and closed by default.",
    "lips": "No separate visible lips, mouth defined by the curved line and soft muzzle shading.",
    "smile": "Default is a small warm closed smile, widening happily when near honey.",
    "teeth": "Small rounded front teeth visible only in big open mouthed happy expressions.",
    "tongue": "Small pink tongue visible only when licking honey off a paw or the jar rim."
  },
  "hair_or_fur": {
    "type": "Short soft plush cartoon fur with a slightly fuzzy stylized 3D rendered edge.",
    "hairstyle": "Not applicable, fur only.",
    "fur_density": "Medium to high density, giving a soft huggable plush toy quality.",
    "fur_softness": "Very soft, slightly longer and fluffier around the ears, cheeks, and belly.",
    "fur_direction": "Flows downward and outward from the crown of the head, and outward from the spine toward the belly.",
    "fur_layering": "Two tone layering, medium brown base coat with a cream underlayer on the muzzle, chest, belly, inner ears, and paw pads.",
    "fur_color_transitions": "Soft feathered blend where brown meets cream on the muzzle and belly, no hard edges.",
    "whiskers": "Not prominently featured, a few faint short whiskers may appear near the muzzle in close up renders."
  },
  "limbs_and_extremities": {
    "tail": "Very small round stub tail, barely visible, matches the base brown fur tone.",
    "paws_or_hands": "Large round paws relative to the limbs, cream colored pads, always shown holding or near the honey jar.",
    "claws": "Small rounded non threatening claw tips, only faintly visible, never sharp looking.",
    "skin_or_fur_base": "Base fur color functions as the skin layer, no bare skin shown except the nose and paw pads.",
    "skin_tone": "Not applicable to the body, nose is glossy black, paw pads are soft cream pink.",
    "skin_texture": "Nose has a smooth glossy highlight, paw pads have a soft matte texture."
  },
  "wardrobe": {
    "materials": "No clothing on the body to preserve the plush bear silhouette, honey jar is glass with a warm amber tint and a tied fabric lid cover.",
    "clothing_items": ["None by default, bare fur is the preferred presentation"],
    "accessories": ["None mandatory beyond the honey jar itself"],
    "shoes": "None, bare rounded feet.",
    "equipment": "Always carries a small round glass honey jar filled with warm amber honey, jar has a red and white checkered fabric cover tied with twine around the lid.",
    "props": ["A wooden honey dipper occasionally resting in the jar", "A small drip of honey on one paw in eating themed art"]
  },
  "color_palette": {
    "primary": "#8B5A2B medium brown base coat",
    "secondary": "#6B4324 deeper brown shading tone",
    "accent": "#EADFC8 cream muzzle chest and belly tone",
    "eyes": "#4A2E17 deep warm brown iris",
    "skin_or_fur_base": "#8B5A2B matches primary coat",
    "detail_hex_list": ["#8B5A2B", "#6B4324", "#EADFC8", "#4A2E17", "#F4A93D", "#C0392B", "#2B1B12"]
  },
  "rendering": {
    "style": "Cute stylized 3D animation look with soft plush shading.",
    "illustration_style": "Rounded soft shaded 3D render or an equivalent 2D cel approximation, subsurface scattering style softness on ears and cheeks, no sharp specular highlights.",
    "lighting": "Warm soft key light from upper left with a gentle warm ambient bounce, evokes a cozy storybook feel.",
    "composition": "Centered mascot framing, honey jar always included in frame when full body is shown.",
    "camera": "Slight low angle three quarter view for a warm approachable read.",
    "framing": "Full body framing with padding for sticker and icon use, close crop acceptable for face focused expressions.",
    "background_compatibility": "Warm cream, soft green, or honey gold flat backgrounds, avoids cool blue tones that clash with the warm palette.",
    "environment_compatibility": "Forest clearings, cozy dens, honey shops, picnic scenes."
  },
  "poses": {
    "standing": "Upright bipedal stance, feet planted wide, honey jar cradled in both front paws at chest height.",
    "idle": "Sitting position hugging the honey jar close to the chest, eyes half closed in contentment.",
    "walking": "Slow gentle waddling step cycle, jar held steady in both paws, slight side to side sway.",
    "running": "Short quick waddling steps, one paw extended forward, jar hugged tightly to the chest to avoid spilling.",
    "action": "Reaching one paw into the jar to scoop honey while balancing the jar against the belly.",
    "gesture_language": "Hugs the jar tighter when nervous or shy, holds the jar up proudly when happy or offering to share."
  },
  "facial_expressions": {
    "default": "Small warm closed mouth smile with soft gentle eyes.",
    "happy": "Wide open eyes, big open mouth smile showing small rounded teeth, cheeks lifted.",
    "surprised": "Eyes wide and round, mouth small and open in an o shape, ears perked slightly forward.",
    "determined_or_focused": "Eyes narrowed slightly with a focused brow shadow, mouth in a small flat line, usually paired with reaching toward the jar.",
    "sad_or_pouting": "Eyes larger with a slight downward tilt, mouth curved into a small frown, jar held closer to the chest for comfort."
  },
  "consistency_rules": {
    "always_identical": ["Medium brown body with cream muzzle chest and belly", "Small round cub proportions", "Deep brown eyes", "Round ears and stub tail", "Constant presence of the honey jar with checkered lid cover"],
    "never_change": ["Species must remain a bear, never reinterpreted as another animal", "Must always be shown small and cub proportioned, never a large adult bear", "Honey jar must never be removed from the core design when the character is shown full body"],
    "mandatory_colors": ["#8B5A2B primary coat", "#6B4324 shading tone", "#EADFC8 muzzle and belly", "#4A2E17 eye color", "#F4A93D honey color"],
    "mandatory_proportions": ["Head to body ratio near 1 to 1.3", "Limbs about one quarter of total body height", "Round belly as the widest part of the torso"],
    "mandatory_accessories": ["Honey jar with red and white checkered fabric lid cover whenever full body is shown"],
    "mandatory_clothing": ["None, bare fur is the default and preferred state"],
    "mandatory_rendering_style": "Soft stylized 3D plush shading or an equivalent soft cel 2D style, never photorealistic bear fur.",
    "mandatory_silhouette": "Compact rounded cub silhouette, big round head, short round body, short stubby limbs, honey jar held at chest height.",
    "common_ai_mistakes": ["Drawing an adult sized realistic brown bear instead of a small cub", "Omitting the honey jar entirely", "Making the fur photorealistic instead of soft plush stylized", "Losing the cream muzzle and belly contrast", "Changing eye color away from deep brown"],
    "identity_drift_prevention": ["Always restate the small brown bear cub holding a honey jar description before generating new poses", "Always include the checkered lid cover detail on the honey jar", "Always keep the cub sized proportions explicit in the prompt"],
    "cross_model_consistency": ["Lead every prompt with the fixed description a small brown bear holding a honey jar cute stylized 3D animation before adding scene detail", "Keep the same hex codes across every prompt and model", "Avoid vague style words like adorable or fluffy alone, pair them with the explicit proportion and color specification"]
  }
}'::jsonb,
'A small brown bear cub mascot character named Bubu si Beruang, round cub proportioned body, large round head with a short rounded muzzle, deep warm brown eyes with a soft catchlight, large glossy black nose, small closed mouth smile, small round ears with cream inner fur, cream colored muzzle chest and belly, short stubby limbs, cradling a small round glass honey jar with a red and white checkered fabric lid cover in both front paws, soft stylized 3D plush shading, warm soft key light from upper left, cozy honey gold flat background, centered full body composition, high consistency character design',
'realistic bear, adult sized bear, aggressive or fierce expression, sharp claws, missing honey jar, photorealistic fur, human clothing, bipedal human body, human hands, cool blue color palette, harsh dramatic lighting, distorted proportions, extra limbs, blurry, low detail, text, watermark, signature',
'CHARACTER BIBLE: BUBU SI BERUANG. Species and Archetype: a small round bodied brown bear cub mascot inseparable from his honey jar, designed to read as gentle, cuddly, and endlessly warm. Core Silhouette: compact rounded shape, a large round head merged into a short round body, short stubby limbs, small round ears, a stub tail, with the honey jar forming a secondary recognizable silhouette element held at chest height. Proportions: head to body ratio approximately 1 to 1.3, limbs about one quarter of total body height, round belly as the widest part of the torso. Head and Face: smooth rounded forehead, soft rounded cheeks, a short rounded muzzle blending into a gentle jaw with no hard edges, small round forward facing ears lined with pale cream fur. Eyes: medium round deep brown irises with a subtle gradient from caramel center to chocolate rim, large round black pupils, one soft catchlight per eye for a kind gaze, no individual lashes, brow shading conveying warmth rather than true eyebrows. Nose and Mouth: large glossy black nose, simple curved mouth line with a default small warm smile, small rounded front teeth visible only in big happy smiles, small pink tongue visible only when licking honey. Coat: short soft plush stylized fur, medium brown base coat hex 8B5A2B with deeper brown shading hex 6B4324, cream underlayer hex EADFC8 on the muzzle chest belly and inner ears, soft feathered color transitions with no hard edges. Equipment: always carries a small round glass honey jar filled with warm amber honey hex F4A93D, jar has a red and white checkered fabric cover tied with twine around the lid, this jar is a mandatory element of the character whenever shown full body. Wardrobe: no clothing on the body, bare fur is the default and preferred presentation. Rendering Style: soft stylized 3D plush shading with gentle subsurface softness on the ears and cheeks, or an equivalent soft cel 2D approximation, warm soft key light from the upper left with a warm ambient bounce, never photorealistic bear fur rendering. Composition: centered mascot framing with the honey jar always visible in full body shots, warm cream or honey gold backgrounds preferred over cool tones. Consistency Mandate: every generation must preserve the medium brown and cream coloring, the small cub proportions, the deep brown eyes, the round ears and stub tail, and the honey jar with its checkered lid cover exactly as specified, must never become an adult sized or photorealistic bear, must never lose the honey jar in full body compositions, and must always restate this coat color, eye color, proportion, and honey jar description at the start of every new prompt to prevent identity drift across GPT Image, Imagen, Flux, Midjourney, Stable Diffusion, Recraft, and Ideogram.'
);

INSERT INTO "Character" ("id", "name", "category", "description", "promptConsistency", "characterBible", "positivePrompt", "negativePrompt", "masterPrompt") VALUES (gen_random_uuid(),
'Nino si Ninja',
'Humanoid',
'A young ninja who is clumsy but always enthusiastic.',
'A clumsy chibi ninja boy wearing a black ninja outfit, face mask, headband, anime style.',
'{
  "identity": "Nino si Ninja is a young chibi proportioned ninja boy whose enthusiasm always outpaces his coordination, a lovable clumsy trainee character built for comedic anime style action scenes and heartfelt determination beats.",
  "silhouette": "Chibi humanoid silhouette, oversized round head on a small compact body, short limbs, flowing headband tails and a loose ninja tunic silhouette that reads clearly even in fast action poses.",
  "body_proportions": "Chibi proportion near 1 to 2 head to body ratio, short arms and legs, small hands and feet, torso slightly rounded rather than athletic to preserve the youthful clumsy read.",
  "body_language": "Energetic, eager, off balance, frequently mid stumble or overreaching for a landing.",
  "anatomy": "Simplified stylized humanoid anatomy, soft joints, minimal muscle definition, exaggerated chibi head to body ratio typical of anime mascot design.",
  "posture": "Default posture leans slightly forward with arms out for balance, knees slightly bent as if always about to trip or leap.",
  "head_and_face": {
    "head_proportions": "Large round head relative to the body, rounded cranium with a shorter lower face area covered mostly by the mask.",
    "face_proportions": "Large eyes dominate the visible upper face area since the lower half is covered by the mask, eyebrows and forehead carry most of the visible expression.",
    "forehead": "Smooth light tan forehead partially covered by the headband, a few loose black hair spikes poke out above the band.",
    "cheeks": "Softly rounded cheeks, mostly hidden by the mask but visible at the upper edge near the eyes.",
    "jaw": "Not visible, fully covered by the black face mask at all times.",
    "chin": "Not visible, covered by the mask.",
    "ears": "Small human ears mostly hidden beneath the headband and hair, only the lower lobe occasionally visible."
  },
  "eyes": {
    "shape": "Large expressive anime style eyes, slightly upturned outer corners for an eager determined look.",
    "iris": "Deep brown iris with a warm undertone.",
    "iris_gradient": "Gradient from a lighter warm brown near the pupil to a darker brown at the outer rim.",
    "iris_texture": "Classic anime style iris with two to three light streak highlights for shine and expressiveness.",
    "pupils": "Medium round black pupils that widen noticeably in surprised or clumsy fall reactions.",
    "reflections_catchlights": "One large primary catchlight upper left and one small secondary catchlight lower right in each eye.",
    "eyelashes": "Minimal short lash indication on the upper lid only, kept simple for the anime chibi style.",
    "eyebrows": "Expressive thick black eyebrows visible above the headband, angled upward at the inner corner for an eager enthusiastic look."
  },
  "nose_mouth": {
    "nose": "Very small simplified nose indicated by a tiny line or dot, mostly hidden under the mask edge.",
    "mouth": "Not visible, fully covered by the black face mask at all times, expression conveyed through eyes and eyebrows instead.",
    "lips": "Not applicable, covered by the mask.",
    "smile": "Implied through eye shape and eyebrow angle since the mouth is never shown, eyes curve upward into a happy arc for a smile.",
    "teeth": "Not applicable, always covered by the mask.",
    "tongue": "Not applicable, always covered by the mask."
  },
  "hair_or_fur": {
    "type": "Short spiky black anime style hair.",
    "hairstyle": "Messy spiky hair with several defined points, a few strands escaping forward over the headband for a scrappy energetic look.",
    "fur": "Not applicable, human character.",
    "whiskers": "Not applicable.",
    "fur_density": "Not applicable.",
    "fur_softness": "Not applicable.",
    "fur_direction": "Hair spikes point generally upward and slightly backward, with two forward facing strands framing the face.",
    "fur_layering": "Not applicable.",
    "fur_color_transitions": "Hair rendered in a flat glossy black hex 100E0C with a subtle blue toned highlight streak for shine."
  },
  "limbs_and_extremities": {
    "tail": "Not applicable.",
    "paws_or_hands": "Small simplified hands with fingerless dark grey gloves, often shown in a mid air balancing gesture.",
    "claws": "Not applicable.",
    "skin_or_fur_base": "Light warm tan skin tone across visible face and hand areas.",
    "skin_tone": "#F2C9A0 light warm tan.",
    "skin_texture": "Smooth flat cel shaded skin with minimal texture, one soft shadow tone for form."
  },
  "wardrobe": {
    "materials": "Matte black cloth tunic and pants, soft leather belt and pouch, woven cotton headband, cloth face mask.",
    "clothing_items": ["Black long sleeved ninja tunic with a wrap style front closure", "Black loose fitting ninja pants tapered at the ankle", "Dark grey sash belt tied at the waist", "Black cloth face mask covering nose mouth and chin", "Red headband with a small silver plate centered on the forehead"],
    "accessories": ["Small brown leather pouch attached to the belt", "Fingerless dark grey gloves"],
    "shoes": "Black tabi style split toe ninja sandals.",
    "equipment": "A single wooden training kunai tucked into the belt, blunt and non threatening in design for the clumsy trainee theme.",
    "props": ["Loose bandage wrap on one forearm suggesting frequent minor training mishaps"]
  },
  "color_palette": {
    "primary": "#1C1C1C matte black outfit",
    "secondary": "#4A4A4A grey sash and glove tone",
    "accent": "#C0392B red headband",
    "eyes": "#4A2E17 deep warm brown iris",
    "skin_or_fur_base": "#F2C9A0 light warm tan skin",
    "detail_hex_list": ["#1C1C1C", "#4A4A4A", "#C0392B", "#4A2E17", "#F2C9A0", "#100E0C", "#B0B0B0"]
  },
  "rendering": {
    "style": "Chibi anime cartoon style with clean cel shading.",
    "illustration_style": "Bold clean linework, two tone flat cel shading per material, exaggerated chibi proportions typical of anime mascot art.",
    "lighting": "Bright even key light from upper left with minimal shadow contrast to keep the energetic lighthearted tone.",
    "composition": "Dynamic off balance poses are encouraged to reinforce the clumsy personality, centered mascot framing for icon use.",
    "camera": "Three quarter dynamic angle for action poses, straight on front view for icon and reference use.",
    "framing": "Full body framing with room for headband tails and cloth movement to extend beyond the base silhouette.",
    "background_compatibility": "Flat solid backgrounds or simple stylized dojo and rooftop scenes, avoids busy photorealistic backgrounds.",
    "environment_compatibility": "Training dojo courtyards, rooftop scenes at dusk, bamboo forests, obstacle course settings."
  },
  "poses": {
    "standing": "Slightly off balance ready stance, one foot forward, arms loosely raised as if about to overcorrect.",
    "idle": "Shifting weight foot to foot, one hand adjusting the headband, headband tails swaying gently.",
    "walking": "Slightly exaggerated bouncy step with arms swinging wide for balance.",
    "running": "Leaning far forward, arms pumping, headband tails streaming straight back, one classic mid stumble variant with arms flailing.",
    "action": "Mid air leap with a training kunai raised, expression eager, one leg still trailing behind as if the jump was not fully planned.",
    "gesture_language": "Uses big broad arm gestures for enthusiasm, freezes with arms out wide when caught mid stumble, thumbs up pose for triumphant determined moments."
  },
  "facial_expressions": {
    "default": "Eyes curved into a cheerful upward arc implying a hidden smile beneath the mask, eyebrows relaxed and slightly raised.",
    "happy": "Eyes squeezed into bright joyful crescents, eyebrows lifted high, small sparkle catchlights added.",
    "surprised": "Eyes fully round and wide, eyebrows shot upward, pupils small, classic clumsy fall reaction.",
    "determined_or_focused": "Eyes narrowed with a sharp focused gaze, eyebrows angled steeply downward at the inner corner, a small flame like sparkle sometimes added near the eyes for emphasis.",
    "sad_or_pouting": "Eyes larger with downturned outer corners, eyebrows tilted inward and upward in a worried shape, headband tail drooping slightly in the pose."
  },
  "consistency_rules": {
    "always_identical": ["Black ninja tunic and pants", "Red headband with silver plate", "Black face mask always covering the lower face", "Spiky black hair with two forward strands", "Chibi head to body ratio"],
    "never_change": ["Face mask must never be removed or shown lowered, the mouth is never depicted", "Must remain a chibi proportioned young character, never aged up to an adult realistic ninja", "Outfit color must remain black with the red headband as the only strong accent color"],
    "mandatory_colors": ["#1C1C1C outfit", "#C0392B headband", "#4A2E17 eye color", "#F2C9A0 skin tone", "#100E0C hair color"],
    "mandatory_proportions": ["Chibi head to body ratio near 1 to 2", "Large eyes occupying most of the visible upper face", "Short limbs relative to the oversized head"],
    "mandatory_accessories": ["Red headband with silver plate", "Brown leather belt pouch", "Fingerless grey gloves"],
    "mandatory_clothing": ["Black wrap front tunic", "Black tapered pants", "Black face mask", "Black tabi sandals"],
    "mandatory_rendering_style": "Clean chibi anime cel shading with bold linework, never photorealistic rendering.",
    "mandatory_silhouette": "Oversized round head on a small compact body with flowing headband tails and a loose tunic silhouette.",
    "common_ai_mistakes": ["Removing or lowering the face mask to reveal the mouth", "Aging the character into a realistic adult ninja proportion", "Changing the headband color away from red or removing the silver plate", "Adding a full katana or realistic bladed weapon instead of the blunt training kunai", "Losing the chibi oversized head proportion"],
    "identity_drift_prevention": ["Always restate the clumsy chibi ninja boy black outfit face mask headband anime style description before generating new poses", "Always specify that the mouth is covered and never shown", "Always keep the chibi head to body ratio explicit in the prompt"],
    "cross_model_consistency": ["Lead every prompt with the fixed description a clumsy chibi ninja boy wearing a black ninja outfit face mask headband anime style before adding scene detail", "Keep the same hex codes across every prompt and model", "Explicitly state face mask always on to prevent models from defaulting to an uncovered anime face"]
  }
}'::jsonb,
'A clumsy chibi ninja boy character named Nino si Ninja, oversized round head on a small compact chibi body, large expressive anime eyes with warm brown gradient iris and bright catchlights, thick expressive black eyebrows, black face mask fully covering nose mouth and chin, spiky black hair with two forward framing strands, red headband with a small silver plate, black wrap front ninja tunic, black tapered ninja pants, dark grey sash belt with a brown leather pouch, fingerless dark grey gloves, black tabi split toe sandals, wooden training kunai tucked into the belt, dynamic slightly off balance action pose, clean chibi anime cel shading, bold linework, bright even lighting, flat solid background, high consistency character design',
'realistic adult proportions, exposed mouth, mask removed, realistic bladed katana, muscular athletic build, photorealistic skin texture, dark gritty color palette, missing headband, missing face mask, missing eyebrows, extra limbs, distorted proportions, blurry, low detail, text, watermark, signature',
'CHARACTER BIBLE: NINO SI NINJA. Species and Archetype: a young chibi proportioned ninja trainee whose boundless enthusiasm always outpaces his coordination, designed as a comedic yet endearing anime style mascot. Core Silhouette: an oversized round head on a small compact body, short limbs, flowing headband tails, and a loose ninja tunic silhouette that reads clearly even in fast dynamic action poses. Proportions: chibi head to body ratio near 1 to 2, short arms and legs, small hands and feet, a slightly rounded rather than athletic torso to preserve the youthful clumsy read. Head and Face: large round head with a smooth light tan forehead partly covered by the headband, softly rounded cheeks mostly hidden by the mask, the jaw, chin, and mouth permanently covered by a black cloth face mask that is never removed or lowered in any depiction. Eyes: large expressive anime eyes with a deep warm brown gradient iris, two to three light streak highlights, a primary and secondary catchlight in each eye, thick expressive black eyebrows angled upward at the inner corner for an eager look, since the mouth is never shown all smiling and frowning expression is carried entirely through the eyes and eyebrows. Hair: short spiky black anime hair with a subtle blue toned highlight streak, two forward facing strands framing the face, hair spikes point upward and slightly backward. Wardrobe: black long sleeved wrap front ninja tunic, black tapered ninja pants, dark grey sash belt with a small brown leather pouch, fingerless dark grey gloves, black tabi style split toe sandals, and a mandatory red headband with a small silver plate centered on the forehead. Equipment: a single blunt wooden training kunai tucked into the belt, intentionally non threatening to reinforce the trainee theme, occasionally paired with a loose bandage wrap on one forearm from training mishaps. Rendering Style: chibi anime cartoon style with bold clean linework and flat two tone cel shading per material, bright even key light from the upper left with minimal shadow contrast for a lighthearted energetic tone, never photorealistic rendering. Composition: dynamic off balance poses are encouraged to reinforce the clumsy personality, centered full body mascot framing with room for headband tails and cloth movement to extend past the base silhouette. Consistency Mandate: every generation must preserve the black tunic and pants, the red headband with silver plate, the permanently covered mouth beneath the black face mask, the spiky black hair with two forward strands, and the chibi head to body ratio exactly as specified, must never reveal the mouth, must never age the character into a realistic adult ninja, and must always restate this outfit, mask, headband, and proportion description at the start of every new prompt to prevent identity drift across GPT Image, Imagen, Flux, Midjourney, Stable Diffusion, Recraft, and Ideogram.'
);

INSERT INTO "Character" ("id", "name", "category", "description", "promptConsistency", "characterBible", "positivePrompt", "negativePrompt", "masterPrompt") VALUES (gen_random_uuid(),
'Astro-Bot',
'Robot',
'A tiny astronaut robot that is endlessly curious.',
'A cute miniature astronaut robot with glowing blue eyes, futuristic sci-fi style.',
'{
  "identity": "Astro-Bot is a tiny curious astronaut robot mascot, a compact friendly explorer character whose glowing blue visor eyes and rounded futuristic chassis express constant wonder and eagerness to discover new things.",
  "silhouette": "Compact rounded robot silhouette, a large round helmet head fused to a smaller rounded body pod, short stubby limbs ending in simple rounded manipulators, small antenna on top, no sharp mechanical spikes anywhere.",
  "body_proportions": "Head or helmet to body ratio near 1 to 1.4, short limbs about one fifth of total body height, torso slightly narrower than the helmet for a top heavy cute read.",
  "body_language": "Eager and inquisitive, tends to lean or tilt the whole head forward toward new objects, antenna bobs when excited.",
  "anatomy": "Simplified stylized robot construction, smooth rounded plating over visible joint segments at the shoulders hips and neck, no exposed wiring, all mechanical detail kept minimal and toylike.",
  "posture": "Slight forward lean with the head tilted curiously, short legs planted a little wider than the body for stability.",
  "head_and_face": {
    "head_proportions": "Large rounded helmet shaped head, dome like, slightly flattened at the front where the visor sits.",
    "face_proportions": "The glowing visor occupies nearly the entire front face area, functioning as both eyes and expressive face plate.",
    "forehead": "Smooth glossy white helmet shell above the visor with a single thin grey panel seam line.",
    "cheeks": "Not applicable in the traditional sense, side helmet panels curve smoothly down to the neck joint.",
    "jaw": "Not applicable, helmet shell continues in a smooth curve to the small neck joint ring.",
    "chin": "Not applicable, replaced by the lower curve of the visor and helmet shell.",
    "ears": "Not applicable, small rounded audio sensor bumps sit at the sides of the helmet where ears would be."
  },
  "eyes": {
    "shape": "Single wide rounded rectangular visor that functions as both eyes, softly rounded at all four corners.",
    "iris": "Not applicable in the biological sense, the visor itself displays two simplified glowing blue eye shapes.",
    "iris_gradient": "The glowing blue eye shapes have a gradient from a bright white hot core to a soft cyan blue outer glow.",
    "iris_texture": "Smooth soft glow with a light scan line texture suggesting a digital display surface.",
    "pupils": "The two displayed eye shapes are simple rounded ovals that can shrink for focus or widen for surprise, functioning like digital pupils.",
    "reflections_catchlights": "A single soft white glare reflection near the top of the visor to suggest a curved glass or polycarbonate surface.",
    "eyelashes": "Not applicable.",
    "eyebrows": "Not applicable, expression is conveyed by the shape and angle of the two glowing digital eye ovals on the visor."
  },
  "nose_mouth": {
    "nose": "Not applicable, no nose on the smooth helmet shell.",
    "mouth": "Not applicable, no physical mouth, small vertical row of three tiny status lights beneath the visor occasionally pulses to suggest speech or beeping.",
    "lips": "Not applicable.",
    "smile": "Implied through the upward curve of the two glowing digital eye shapes rather than a mouth.",
    "teeth": "Not applicable.",
    "tongue": "Not applicable."
  },
  "hair_or_fur": {
    "type": "Not applicable, robot character with a hard glossy shell.",
    "hairstyle": "Not applicable.",
    "fur": "Not applicable.",
    "whiskers": "Not applicable.",
    "fur_density": "Not applicable.",
    "fur_softness": "Not applicable.",
    "fur_direction": "Not applicable.",
    "fur_layering": "Not applicable.",
    "fur_color_transitions": "Not applicable, surface uses panel color blocking instead of fur gradients."
  },
  "limbs_and_extremities": {
    "tail": "Not applicable, a single flexible antenna on top of the helmet functions as the expressive equivalent of a tail, tipped with a small red blinking light.",
    "paws_or_hands": "Short stubby arms ending in simple three fingered rounded manipulator hands, no sharp claw like digits.",
    "claws": "Not applicable, manipulator fingertips are smooth and rounded.",
    "skin_or_fur_base": "Glossy white and light grey painted metal or polycarbonate shell.",
    "skin_tone": "#E8ECF0 primary shell white.",
    "skin_texture": "Smooth glossy painted surface with fine panel seams and small rounded rivets, subtle specular highlights to suggest a hard reflective material."
  },
  "wardrobe": {
    "materials": "Painted metal or polycarbonate shell plating, no fabric clothing since the body itself functions as an astronaut suit silhouette.",
    "clothing_items": ["Built in rounded chest plate resembling a simplified astronaut suit torso panel", "Small backpack style thruster pack on the back with two rounded nozzle vents"],
    "accessories": ["Small circular mission patch decal on the chest plate", "Flexible antenna with a red blinking tip light"],
    "shoes": "Built in rounded boot shaped foot plating, same white and grey shell material as the rest of the body.",
    "equipment": "Small backpack thruster pack, occasionally shown with a short retractable grabber tool extending from one arm.",
    "props": ["A small floating specimen sample orb held in one manipulator hand for exploration themed art", "A miniature planted flag prop for discovery themed scenes"]
  },
  "color_palette": {
    "primary": "#E8ECF0 glossy white shell",
    "secondary": "#B7C0C9 light grey panel and seam tone",
    "accent": "#3FD0FF glowing blue visor eyes and light accents",
    "eyes": "#3FD0FF glowing blue with a white hot core",
    "skin_or_fur_base": "#E8ECF0 matches primary shell",
    "detail_hex_list": ["#E8ECF0", "#B7C0C9", "#3FD0FF", "#4A4F55", "#FF4C4C", "#FFFFFF"]
  },
  "rendering": {
    "style": "Cute miniature sci fi robot mascot style with a soft toylike finish.",
    "illustration_style": "Clean stylized 3D render or an equivalent 2D vector approximation, smooth glossy shading with soft rim lighting to emphasize the rounded plastic and metal shell.",
    "lighting": "Cool ambient sci fi lighting from above with a soft blue rim light echoing the visor glow, subtle glow bloom around the eyes and antenna tip.",
    "composition": "Centered mascot framing, visor glow should always read clearly as the focal point of the face.",
    "camera": "Slight low angle three quarter view to emphasize the large helmet head, straight on front view for icon use.",
    "framing": "Full body framing with padding for icon and sticker extraction, close crop acceptable for helmet focused shots.",
    "background_compatibility": "Dark navy, deep space, or clean white studio backgrounds, glow accents read best against darker backdrops.",
    "environment_compatibility": "Space station interiors, alien planet surfaces, star fields, laboratory settings."
  },
  "poses": {
    "standing": "Balanced stance with feet planted evenly, antenna upright, visor eyes forward and glowing steadily.",
    "idle": "Slight head tilt side to side as if scanning the environment, antenna gently bobbing.",
    "walking": "Small even mechanical steps, arms swinging slightly, thruster pack vents showing a faint idle glow.",
    "running": "Thruster pack vents glowing brighter with a small visible thrust trail, body leaned forward, antenna trailing back.",
    "action": "Reaching forward with one manipulator hand toward a glowing object of interest, visor eyes widened in the digital surprised shape.",
    "gesture_language": "Antenna position signals emotion, upright and still for calm curiosity, rapid bobbing for excitement, drooped for disappointment, visor eye shape shifts are the primary facial gesture."
  },
  "facial_expressions": {
    "default": "Two steady glowing blue rounded oval eye shapes on the visor, centered and calm.",
    "happy": "Eye shapes curve upward into gentle glowing crescents, status lights beneath the visor pulse in a quick rhythm.",
    "surprised": "Eye shapes snap into full wide circles, brightness increases briefly, antenna stands fully upright.",
    "determined_or_focused": "Eye shapes narrow into thin glowing lines angled slightly inward, antenna held still and steady.",
    "sad_or_pouting": "Eye shapes droop at the outer edges into soft downward curves, glow dims slightly, antenna tip lowers."
  },
  "consistency_rules": {
    "always_identical": ["Glossy white and light grey shell coloring", "Glowing blue digital visor eyes", "Rounded dome helmet head fused to a smaller body pod", "Antenna with a red blinking tip light", "Chest plate mission patch decal"],
    "never_change": ["Must remain a robot, never given organic skin or fur", "Visor eye color must remain glowing blue, never shifted to another color", "Must never be given a physical mouth or nose"],
    "mandatory_colors": ["#E8ECF0 primary shell", "#B7C0C9 panel tone", "#3FD0FF visor glow", "#FF4C4C antenna tip light"],
    "mandatory_proportions": ["Helmet to body ratio near 1 to 1.4", "Limbs about one fifth of total body height", "Torso narrower than the helmet"],
    "mandatory_accessories": ["Antenna with red blinking tip light", "Chest plate mission patch decal", "Backpack thruster pack"],
    "mandatory_clothing": ["Built in astronaut style chest plate and boot shell, no separate fabric clothing"],
    "mandatory_rendering_style": "Clean glossy stylized 3D or vector sci fi mascot style with soft rim lighting, never gritty hard surface photoreal mecha rendering.",
    "mandatory_silhouette": "Large rounded dome helmet head fused to a smaller rounded body pod with short stubby limbs and a top mounted antenna.",
    "common_ai_mistakes": ["Rendering a full sized humanoid astronaut instead of a tiny compact robot", "Changing the visor glow color away from blue", "Adding a visible mouth or organic facial features", "Losing the antenna and its red tip light", "Using a harsh gritty mecha rendering style instead of the soft toylike finish"],
    "identity_drift_prevention": ["Always restate the tiny miniature astronaut robot glowing blue eyes futuristic sci fi style description before generating new poses", "Always specify the antenna with red tip light explicitly", "Always keep the helmet to body proportion explicit in the prompt"],
    "cross_model_consistency": ["Lead every prompt with the fixed description a cute miniature astronaut robot with glowing blue eyes futuristic sci fi style before adding scene detail", "Keep the same hex codes across every prompt and model", "Explicitly state no mouth no nose robot face to prevent models from adding unwanted organic facial features"]
  }
}'::jsonb,
'A cute miniature astronaut robot character named Astro-Bot, large rounded dome helmet head fused to a smaller rounded body pod, glossy white and light grey painted shell with fine panel seams, glowing blue digital visor eyes shaped as two rounded ovals with a white hot core and soft cyan outer glow, no visible mouth or nose, small antenna on top with a red blinking tip light, built in astronaut style chest plate with a circular mission patch decal, small backpack thruster pack with two rounded nozzle vents, short stubby arms ending in three fingered rounded manipulator hands, rounded boot shaped feet, clean glossy stylized 3D sci fi mascot rendering with soft blue rim lighting, dark navy deep space background, centered full body composition, high consistency character design',
'organic skin, human face, visible mouth, visible nose, realistic gritty mecha texture, exposed wiring, sharp mechanical spikes, dull matte finish, visor color other than blue, missing antenna, missing chest patch, full sized adult humanoid proportions, distorted proportions, extra limbs, blurry, low detail, text, watermark, signature',
'CHARACTER BIBLE: ASTRO-BOT. Species and Archetype: a tiny curious astronaut robot mascot, a compact friendly explorer whose glowing blue visor eyes and rounded futuristic chassis express constant wonder and eagerness to discover new things. Core Silhouette: a large rounded dome helmet head fused to a smaller rounded body pod, short stubby limbs ending in simple rounded manipulator hands, a flexible top mounted antenna, and no sharp mechanical spikes anywhere on the form. Proportions: helmet to body ratio near 1 to 1.4, limbs about one fifth of total body height, torso slightly narrower than the helmet for a top heavy cute read. Head and Face: smooth glossy white helmet shell with a single thin grey panel seam, small rounded audio sensor bumps where ears would be, and a wide rounded rectangular visor occupying nearly the entire front face that displays two simplified glowing blue digital eye shapes with a white hot core and soft cyan outer glow, a light scan line texture, and a single soft glare reflection near the top suggesting a curved glass surface. Face: no physical mouth or nose, a small vertical row of three tiny status lights beneath the visor occasionally pulses to suggest speech, all expression is carried entirely through the shape and angle of the two glowing digital eye ovals. Shell and Coloring: glossy white primary shell hex E8ECF0, light grey panel and seam tone hex B7C0C9, glowing blue visor and light accents hex 3FD0FF, smooth glossy painted surface with fine seams and small rounded rivets and subtle specular highlights. Antenna and Details: a flexible antenna on top of the helmet tipped with a small red blinking light hex FF4C4C functions as the expressive equivalent of a tail, bobbing when excited and drooping when disappointed. Wardrobe and Equipment: no fabric clothing since the body itself is the astronaut suit silhouette, a built in rounded chest plate with a circular mission patch decal, a small backpack thruster pack with two rounded nozzle vents, and built in rounded boot shaped foot plating. Rendering Style: clean glossy stylized 3D or vector sci fi mascot style with soft rim lighting and subtle glow bloom around the eyes and antenna tip, cool ambient lighting from above with a soft blue rim light, never a gritty hard surface photoreal mecha finish. Composition: centered full body mascot framing with the visor glow always reading as the clear focal point, dark navy or deep space backgrounds preferred to make the glow accents pop. Consistency Mandate: every generation must preserve the glossy white and light grey shell coloring, the glowing blue digital visor eyes, the fused dome helmet and body pod silhouette, the antenna with its red blinking tip, and the chest plate mission patch exactly as specified, must never gain organic skin, a physical mouth, or a full sized adult humanoid body, and must always restate this shell color, visor eye color, and proportion description at the start of every new prompt to prevent identity drift across GPT Image, Imagen, Flux, Midjourney, Stable Diffusion, Recraft, and Ideogram.'
);

INSERT INTO "Character" ("id", "name", "category", "description", "promptConsistency", "characterBible", "positivePrompt", "negativePrompt", "masterPrompt") VALUES (gen_random_uuid(),
'Profesor Hoot',
'Animal',
'A genius owl with thick round glasses who loves reading books.',
'A wise old owl wearing thick round glasses while holding a book, clean vector illustration.',
'{
  "identity": "Profesor Hoot is a genius elder owl character defined by scholarly warmth, thick round glasses, and a constant companionship with books, designed as a wise mentor mascot rendered in clean flat vector illustration.",
  "silhouette": "Rounded owl silhouette, large round head with no visible neck merging into a wide oval body, short wing arms occasionally holding a book, small tufted feather ear points, wide rounded tail feathers at the base.",
  "body_proportions": "Head to body ratio near 1 to 1.1, wide rounded body nearly as tall as the head, short stubby feathered legs, wings proportioned to comfortably hold a book against the chest.",
  "body_language": "Calm, attentive, and thoughtful, frequently tilts the head slightly while reading, one wing resting on an open book page.",
  "anatomy": "Simplified stylized owl anatomy, rounded body form typical of owl mascot design, wings function as simplified arm equivalents for holding props, no exposed talons in most poses.",
  "posture": "Upright perched posture, slight forward lean while reading, wide set feet providing a stable base whether standing or perched on a branch.",
  "head_and_face": {
    "head_proportions": "Very large round head, nearly circular, with a distinct heart shaped or rounded facial disc typical of owls.",
    "face_proportions": "Large glasses and eyes dominate the center of the face, beak is small and centered low on the facial disc.",
    "forehead": "Smooth rounded feathered forehead in a warm brown tone, small tufted feather points near the top suggesting eyebrow like accents.",
    "cheeks": "Soft rounded facial disc feathers framing the glasses on both sides.",
    "jaw": "Not applicable in the traditional sense, facial disc curves smoothly down to the beak and chin feather tuft.",
    "chin": "Small tuft of cream feathers beneath the beak.",
    "ears": "Small feather ear tufts at the top of the head, one often tilted slightly for a thoughtful asymmetrical charm, true ears are hidden beneath feathers as is typical for owls."
  },
  "eyes": {
    "shape": "Very large round eyes typical of owl anatomy, further enlarged in appearance by the thick round glasses lenses.",
    "iris": "Warm amber orange iris.",
    "iris_gradient": "Gradient from a bright golden amber center to a deeper burnt orange outer rim.",
    "iris_texture": "Fine radiating linework for a wise attentive shine, subtle enough to remain clean vector friendly.",
    "pupils": "Large round black pupils, calm and steady, occasionally shown slightly narrowed in focused reading poses.",
    "reflections_catchlights": "One soft catchlight upper left in each eye plus a secondary small glint reflected off the glasses lens.",
    "eyelashes": "Not applicable, owls do not have visible lashes, upper lid rendered as a simple soft feathered edge.",
    "eyebrows": "Not applicable, expression carried by the small feather tufts above the eyes and the angle of the glasses."
  },
  "nose_mouth": {
    "nose": "Not applicable, replaced by a small curved beak at the center of the facial disc.",
    "mouth": "Beak functions as the mouth, small hooked shape, slightly open when speaking or hooting.",
    "lips": "Not applicable, beak has a hard smooth keratin surface instead of lips.",
    "smile": "Implied through the upward curve of the eyes and the gentle angle of the beak tip rather than a true smile.",
    "teeth": "Not applicable, owls have no teeth.",
    "tongue": "Small pale tongue visible only in wide open hooting or surprised beak poses."
  },
  "hair_or_fur": {
    "type": "Soft layered feathers rendered in a clean flat vector style rather than individual feather strand detail.",
    "hairstyle": "Not applicable, feather tufts at the top of the head take the place of hair styling.",
    "fur": "Feathers rather than fur, arranged in simplified overlapping shapes for a clean vector look.",
    "whiskers": "Not applicable.",
    "fur_density": "Feathers rendered as a few large simplified overlapping shapes rather than dense individual feather strands, keeping the clean vector illustration style.",
    "fur_softness": "Implied softness through rounded feather shape edges and soft color shading rather than texture detail.",
    "fur_direction": "Feather shapes flow downward and outward from the crown of the head and from the center of the chest outward to the wings.",
    "fur_layering": "Two tone layering, warm brown body feathers with a cream colored chest and facial disc.",
    "fur_color_transitions": "Soft flat color blocking where brown meets cream, minimal gradient, clean vector edge consistent with the illustration style."
  },
  "limbs_and_extremities": {
    "tail": "Short wide fan shaped tail feathers in the same warm brown tone as the body, visible beneath the folded wings.",
    "paws_or_hands": "Small yellow orange talon feet, typically shown gripping a branch or book edge, wings function as the primary manipulator equivalent for holding books.",
    "claws": "Small rounded talons, visible mainly when perched, kept gentle and non threatening in design.",
    "skin_or_fur_base": "Feathers function as the outer covering, talon feet show a smooth glossy keratin texture.",
    "skin_tone": "Not applicable to the body, talon feet colored a warm yellow orange tone.",
    "skin_texture": "Beak and talons have a smooth glossy keratin finish, feathers are rendered as soft flat matte shapes."
  },
  "wardrobe": {
    "materials": "No fabric clothing on the body, glasses are a warm tortoiseshell or dark brown acetate material, book is cloth bound with a printed paper cover.",
    "clothing_items": ["None on the body, feathers are the natural covering"],
    "accessories": ["Thick round glasses with a dark brown tortoiseshell frame, always worn"],
    "shoes": "None, natural talon feet.",
    "equipment": "A closed or open hardcover book held against the chest with one wing, book cover in a deep warm red or forest green tone with a simple gold accent line.",
    "props": ["A small feather quill pen tucked behind one ear tuft", "A stack of two or three additional books nearby in wider scene compositions"]
  },
  "color_palette": {
    "primary": "#7A5230 warm brown body feathers",
    "secondary": "#5A3B22 deeper brown wing and back shading",
    "accent": "#EADFC8 cream facial disc and chest feathers",
    "eyes": "#E8963C warm amber orange iris",
    "skin_or_fur_base": "#7A5230 matches primary feather tone",
    "detail_hex_list": ["#7A5230", "#5A3B22", "#EADFC8", "#E8963C", "#2B2B2B", "#A83232", "#D98A2B"]
  },
  "rendering": {
    "style": "Clean flat vector illustration style with minimal gradients.",
    "illustration_style": "Bold clean outlines, simplified geometric feather shapes, two to three flat color tones per region, subtle soft shadow blocking rather than painterly shading.",
    "lighting": "Even soft studio style lighting with minimal directional shadow, consistent with a clean flat vector look.",
    "composition": "Centered mascot framing, often shown seated on a branch or stack of books, glasses and open book are consistent focal elements.",
    "camera": "Straight on or gentle three quarter view, favors a calm symmetrical composition over dynamic action angles.",
    "framing": "Full body or bust framing both work well, generous padding for icon and educational material use.",
    "background_compatibility": "Soft cream, warm parchment, or muted forest green flat backgrounds, works well with library or study themed scenes.",
    "environment_compatibility": "Library interiors, cozy study nooks, tree branch perches, classroom settings."
  },
  "poses": {
    "standing": "Upright perched stance on both feet, wings loosely at the sides, head level and attentive.",
    "idle": "Perched on a branch or book stack, one wing resting on an open book, head tilted slightly as if considering a passage.",
    "walking": "Not typical for the character, when shown, a slow careful hopping gait with wings held close for balance.",
    "running": "Rarely depicted, if shown a quick hopping motion with wings spread slightly for balance rather than a realistic sprint.",
    "action": "Wing raised as if mid explanation or lecture, beak slightly open, book held open in the other wing.",
    "gesture_language": "Head tilt communicates curiosity and thought, raised wing communicates explanation or teaching, glasses pushed slightly down the beak bridge with a wing tip communicates skepticism or scrutiny."
  },
  "facial_expressions": {
    "default": "Calm attentive gaze with eyes at a relaxed round shape and beak gently closed.",
    "happy": "Eyes brighten with an added glint highlight, beak opens slightly in a soft hooting smile shape, feather tufts lift slightly.",
    "surprised": "Eyes widen further than usual, glasses catch a brighter glint, beak opens into a small o shape.",
    "determined_or_focused": "Eyes narrow slightly in concentration, one feather tuft raised higher than the other, beak closed firmly.",
    "sad_or_pouting": "Eyes droop slightly at the outer corners, feather tufts lowered, beak angled slightly downward."
  },
  "consistency_rules": {
    "always_identical": ["Warm brown and cream feather coloring", "Thick round dark tortoiseshell glasses always worn", "Large amber orange eyes", "Feather ear tufts at the top of the head", "A book present in most compositions"],
    "never_change": ["Species must remain an owl, never reinterpreted as another bird", "Glasses must never be removed, they are a permanent core identity feature", "Must remain rendered in the clean flat vector illustration style rather than a realistic bird rendering"],
    "mandatory_colors": ["#7A5230 primary feather tone", "#5A3B22 shading tone", "#EADFC8 facial disc and chest", "#E8963C eye color", "#2B2B2B glasses frame"],
    "mandatory_proportions": ["Head to body ratio near 1 to 1.1", "Large glasses and eyes dominating the center of the face", "Wide rounded body nearly as tall as the head"],
    "mandatory_accessories": ["Thick round dark tortoiseshell glasses whenever the character is shown"],
    "mandatory_clothing": ["None, natural feathers are the default and only covering"],
    "mandatory_rendering_style": "Clean flat vector illustration with bold outlines and simplified feather shapes, never photorealistic bird feather rendering.",
    "mandatory_silhouette": "Large round head merging directly into a wide oval body with no visible neck, small feather ear tufts, wide fan tail feathers.",
    "common_ai_mistakes": ["Removing the glasses entirely", "Rendering a photorealistic owl instead of the clean flat vector style", "Losing the cream facial disc and chest contrast against the brown body", "Omitting the book prop in reading themed scenes", "Changing eye color away from warm amber orange"],
    "identity_drift_prevention": ["Always restate the wise old owl thick round glasses holding a book description before generating new poses", "Always include the tortoiseshell glasses explicitly in every prompt", "Always specify the clean vector illustration style to prevent a shift toward photorealism"],
    "cross_model_consistency": ["Lead every prompt with the fixed description a wise old owl wearing thick round glasses while holding a book clean vector illustration before adding scene detail", "Keep the same hex codes across every prompt and model", "Explicitly state flat vector illustration no photorealistic feather texture to keep rendering consistent across different image models"]
  }
}'::jsonb,
'A wise old owl mascot character named Profesor Hoot, large round head merging directly into a wide oval body with no visible neck, warm brown feathers with a cream colored facial disc and chest, thick round dark tortoiseshell glasses framing large amber orange eyes with a golden gradient and soft catchlights, small curved beak, small feather ear tufts at the top of the head with one tilted thoughtfully, short wing arms holding a closed hardcover book with a deep red cover and gold accent line against the chest, small yellow orange talon feet perched on a wooden branch, wide fan shaped brown tail feathers, clean flat vector illustration style, bold outlines, simplified feather shapes, even soft studio lighting, warm parchment background, centered composition, high consistency character design',
'photorealistic owl, realistic feather texture, missing glasses, sharp aggressive talons, dark or muted color palette, harsh dramatic lighting, painterly rendering, missing book, mismatched eye color, distorted proportions, extra limbs, blurry, low detail, text, watermark, signature',
'CHARACTER BIBLE: PROFESOR HOOT. Species and Archetype: a genius elder owl mascot defined by scholarly warmth, permanently worn thick round glasses, and constant companionship with books, rendered as a wise mentor character in clean flat vector illustration. Core Silhouette: a large round head merging directly into a wide oval body with no visible neck, short wing arms sized to comfortably hold a book against the chest, small feather ear tufts at the top of the head, and wide fan shaped tail feathers at the base. Proportions: head to body ratio near 1 to 1.1, a wide rounded body nearly as tall as the head, short stubby feathered legs, large glasses and eyes dominating the center of the facial disc. Head and Face: a smooth rounded warm brown feathered forehead with small tufted feather points, a soft rounded facial disc framing the glasses on both sides, a small curved beak centered low on the disc functioning as the mouth, and a small cream feather tuft beneath the beak as the chin. Eyes: very large round eyes with a warm amber orange iris gradient from bright golden center to deeper burnt orange rim, large round black pupils, a soft catchlight in each eye plus a secondary glint reflected off the glasses lens, no visible lashes, expression carried by the small feather tufts and the angle of the glasses rather than eyebrows. Glasses: thick round glasses with a dark brown tortoiseshell frame hex 2B2B2B, worn at all times as a permanent, non negotiable core identity feature. Feathers: soft layered feathers rendered as a few large simplified overlapping shapes in the clean vector style rather than individual strand detail, warm brown primary tone hex 7A5230 with deeper brown shading hex 5A3B22 on the wings and back, cream facial disc and chest hex EADFC8, soft flat color blocking at the transitions with minimal gradient. Equipment: a closed or open hardcover book held against the chest with one wing, cover in a deep warm red or forest green tone with a simple gold accent line, occasionally paired with a small feather quill tucked behind one ear tuft. Wardrobe: no fabric clothing on the body, feathers are the natural and only covering besides the glasses. Rendering Style: clean flat vector illustration with bold clean outlines, simplified geometric feather shapes, two to three flat color tones per region, even soft studio style lighting with minimal directional shadow, never a photorealistic bird rendering. Composition: centered mascot framing, commonly shown seated on a branch or a stack of books, glasses and an open or held book are consistent focal elements, soft cream, warm parchment, or muted forest green backgrounds preferred. Consistency Mandate: every generation must preserve the warm brown and cream feather coloring, the thick round tortoiseshell glasses, the large amber orange eyes, the feather ear tufts, and the presence of a book prop exactly as specified, must never remove the glasses, must never shift to photorealistic feather rendering, and must always restate this feather color, glasses, eye color, and proportion description at the start of every new prompt to prevent identity drift across GPT Image, Imagen, Flux, Midjourney, Stable Diffusion, Recraft, and Ideogram.'
);
