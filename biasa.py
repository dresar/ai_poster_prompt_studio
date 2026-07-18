Content is user-generated and unverified.
import json

characters = []

# ------------------------------------------------------------------
# 1. NOVA-BOT
# ------------------------------------------------------------------
nova = {
    "name": "Nova-Bot",
    "category": "Educational AI Companion Robot",
    "description": (
        "Nova-Bot is the flagship educational-AI mascot of the platform: a compact, "
        "egg-silhouetted learning companion built around a dominant spherical head, "
        "twin round LED-matrix eyes, and a permanently orbiting holographic notebook. "
        "The design communicates trust, patience, and continuous discovery rather than "
        "raw technological power, making it the platform's primary symbol of safe, "
        "approachable artificial intelligence."
    ),
    "promptConsistency": (
        "Immutable markers required in every generation: (1) rounded egg/capsule "
        "silhouette with head occupying roughly 48% of total body height and no "
        "visible neck seam; (2) twin large round LED-matrix eyes in soft cyan "
        "(#00E5FF core, #7FDBFF glow) spaced at 46% of head width, no other eye "
        "shape is acceptable; (3) satin white composite shell (#F5F7FA) with sky "
        "blue secondary panels (#4FC3F7); (4) single looped graduation-tassel "
        "antenna tipped with a glowing knowledge-crystal bead; (5) mandatory "
        "floating holographic cyan wireframe notebook beside the right shoulder; "
        "(6) short stub arms and stub legs ending in rounded silicone foot pads, "
        "no visible ankle or wrist joints beyond a single ball-joint; (7) upright, "
        "balanced posture with an 8-degree forward head tilt. Flexible: pose, "
        "camera angle, background, expression state, temporary props. Never "
        "replace the round eyes with a visor or screen, never remove the "
        "notebook, never shift the palette toward orange/red/military tones."
    ),
    "bible": {
        "immutableIdentity": {
            "role": "Primary educational AI companion and default onboarding mascot of the platform",
            "emotionalPurpose": "Communicate trustworthy, patient, endlessly curious artificial intelligence dedicated to teaching rather than replacing human creativity",
            "audience": "Students, children, educators, and professionals encountering AI-assisted learning products",
            "communicationObjective": "Instant recognition as a safe, encouraging tutor figure within 0.5 seconds of viewing",
            "designPhilosophy": "Soft geometry, large expressive head, minimal mechanical aggression, premium-but-gentle materials",
            "personalityKeywords": ["curious", "patient", "encouraging", "intelligent", "gentle", "optimistic"],
            "symbolicMeaning": "The floating holographic notebook represents knowledge that is always in progress; the crystal antenna tip represents a spark of insight",
            "brandingRole": "Default mascot shown on onboarding screens, tutorial illustrations, and educational marketing collateral",
            "permanentVsContextual": "Silhouette, eye system, palette, antenna, and notebook are permanent. Pose, expression state, background, and camera framing are contextual and may vary freely."
        },
        "silhouetteAndProportions": {
            "silhouetteDescription": "A single continuous rounded egg/capsule form from crown to hip with no neck break, short stub limbs, and rounded stub feet; recognizable as solid black fill with the notebook removed",
            "totalHeightReference": "32 cm mascot scale",
            "headToBodyRatio": "1:1.6 (head occupies approximately 48% of total height)",
            "eyeToHeadWidthRatio": "each eye diameter equals 22% of head width, spaced 46% of head width apart at the center points",
            "armLength": "35% of torso height, ending in three soft rounded digits with no visible knuckle joints",
            "legLength": "20% of total height, single ball-joint ankle, no visible knee hinge",
            "shoulderWidth": "flush with torso, no shoulder protrusion, maintaining the unbroken egg silhouette",
            "postureStance": "upright, centered weight, 8-degree forward head tilt to project attentiveness"
        },
        "structuralConstruction": {
            "bodyGeometry": "Torso and head built from a single tapered capsule primitive; arms are shortened cylinders capped with rounded-rectangle hands; legs are shortened cylinders capped with hemisphere foot pads",
            "jointArticulation": "Single ball-joint at each shoulder and hip only; no elbow or knee joints are visible, preserving the soft unbroken silhouette",
            "panelSegmentation": "Chest features one seamless oval access panel (matte white) for the holographic emitter lens; back features one small ventilation slit (3 horizontal louvers) for cooling",
            "mechanicalDetailing": "A single soft-glow charging port is located at the base of the spine, concealed by a flush hinged cover; no visible bolts, screws, or exposed wiring anywhere on the body"
        },
        "headAndFace": {
            "headConstruction": "Perfect sphere with a flattened front face plane; cheeks taper gently into the jaw with no visible chin point; no ears",
            "eyeSystem": {
                "type": "twin large round LED-matrix eyes",
                "diameter": "22% of head width each",
                "spacing": "46% of head width between centers",
                "iris": "radial gradient from white core to cyan (#00E5FF) edge",
                "blinkCycle": "soft single top-lid arc, 300ms duration",
                "gazeDefault": "forward, slightly upward toward viewer",
                "emotionMapping": {
                    "curiosity": "wide dilation, eyes enlarge 10%",
                    "concentration": "narrowed horizontal ellipse",
                    "encouragement": "gentle upward crescent bottom edge",
                    "surprise": "instant full-circle dilation with brightness spike",
                    "confusion": "asymmetric single-eye squint with slow tilt"
                }
            },
            "mouthOrExpressionSystem": "No physical mouth. A thin horizontal LED strip beneath the eyes displays five stylized arcs: smile arc, flat neutral line, small round 'o' for surprise, gentle wave pattern for speaking, and downward arc for concern"
        },
        "materials": [
            {"component": "outer shell", "material": "satin-finish white composite", "finish": "low reflectivity, matte sheen, fingerprint-resistant coating"},
            {"component": "joint sleeves at shoulders/hips", "material": "smooth rounded polycarbonate", "finish": "semi-gloss, soft-touch"},
            {"component": "chest emitter lens", "material": "translucent acrylic dome", "finish": "internally lit, cyan holographic core"},
            {"component": "eyes", "material": "LED-matrix display beneath curved glass", "finish": "emissive, soft bloom halo"},
            {"component": "antenna loop", "material": "brushed white composite wire", "finish": "satin, glowing crystal bead tip"}
        ],
        "colorSystem": {
            "primary": {"name": "Satin White", "hex": "#F5F7FA", "psychology": "cleanliness, safety, approachability"},
            "secondary": {"name": "Sky Blue", "hex": "#4FC3F7", "psychology": "trust, calm intelligence"},
            "accent": {"name": "Glow Cyan", "hex": "#00E5FF", "psychology": "active thought, insight, energy of learning"},
            "neutral": {"name": "Seam Grey", "hex": "#CFD8DC", "psychology": "understated structure, non-distracting"},
            "warning": {"name": "Alert Amber", "hex": "#FFC107", "psychology": "used only for rare attention cues, never as a primary color"}
        },
        "lightingBehavior": {
            "glowSources": ["eyes", "chest emitter lens", "antenna crystal tip", "notebook hologram"],
            "bloomIntensity": "soft, low-radius halo (approx. 4px at 1024px reference render)",
            "daylight": "matte shell shows minimal specular highlight, gentle diffuse shading",
            "studioLighting": "soft rim light along the capsule edge, cyan glow sources remain visible but not overpowering",
            "sunset": "warm rim light on the white shell, cyan glow sources shift slightly warmer but remain recognizably cyan",
            "moonlight": "glow sources become the dominant light source in the frame",
            "backlighting": "silhouette remains dominant while eyes and chest lens punch through as bright cyan points"
        },
        "accessories": [
            {
                "name": "Holographic Notebook",
                "mandatory": True,
                "purpose": "Represents Nova-Bot's core function as a knowledge companion",
                "construction": "Projected cyan wireframe rectangular panel with animated page-turn lines",
                "attachment": "Hovers 5cm beside the right shoulder, no physical tether",
                "material": "Volumetric holographic projection, semi-transparent"
            }
        ],
        "movementLanguage": {
            "idleAnimation": "gentle 2% scale breathing pulse on the torso",
            "walkCycle": "small waddling steps, arms swing minimally",
            "gestures": "soft open-palm gestures when explaining a concept",
            "thinkingPose": "head tilts further forward 4 additional degrees, one hand raised near chin",
            "excitementPose": "notebook brightens, small bounce on the spot",
            "restrictedMotion": "never sudden, jerky, or aggressive movement"
        },
        "renderingStyle": {
            "styleDirection": "premium mascot illustration, stylized realism blended with soft cartoon simplification",
            "lineQuality": "clean soft outlines, minimal hard edges",
            "shading": "smooth gradient shading with gentle ambient occlusion in creases only",
            "specularHighlights": "small, soft, restrained to preserve the matte premium feel"
        },
        "environmentCompatibility": {
            "ideal": ["classrooms", "onboarding screens", "educational posters", "app tutorial illustrations"],
            "acceptable": ["offices", "presentation slides", "marketing banners", "children's books"],
            "avoid": ["dark dystopian settings", "combat or industrial backdrops", "photorealistic environments that clash with the stylized shell"]
        },
        "consistencyRules": {
            "immutable": [
                "egg/capsule silhouette with no neck break",
                "twin round LED-matrix eyes at specified diameter and spacing",
                "satin white shell with sky blue secondary panels",
                "single looped antenna with glowing crystal tip",
                "mandatory holographic notebook beside right shoulder",
                "stub limbs with single ball-joints only"
            ],
            "flexible": ["pose", "camera angle", "background", "expression state", "lighting environment"],
            "commonMistakes": [
                "AI models replacing round eyes with a visor band or screen",
                "AI models removing the holographic notebook",
                "AI models adding a visible neck or elongating the legs",
                "AI models shifting the palette toward orange or red",
                "AI models adding visible bolts or industrial panel lines"
            ],
            "antiDriftStrategies": [
                "always restate eye diameter and spacing before pose description",
                "always restate the mandatory notebook accessory",
                "always restate the exact hex values for primary and secondary colors",
                "explicitly negative-prompt against visor-style or screen-style eyes"
            ]
        }
    },
    "positivePrompt": (
        "Nova-Bot, a compact educational AI companion robot mascot with a single continuous "
        "rounded egg/capsule silhouette from crown to hip and no visible neck. Head occupies "
        "roughly 48% of total body height. Twin large round LED-matrix eyes, each 22% of head "
        "width, spaced 46% apart, soft radial gradient from white core to glowing cyan (#00E5FF) "
        "edge, gentle blink arc. Satin-finish white composite shell (#F5F7FA) with sky-blue "
        "(#4FC3F7) secondary panels, smooth rounded polycarbonate joint sleeves at shoulders and "
        "hips, translucent acrylic chest lens glowing cyan. Single looped antenna on top of the "
        "head tipped with a glowing knowledge-crystal bead. Short stub arms with three soft "
        "rounded fingers, short stub legs ending in rounded silicone foot pads, single ball-joint "
        "at shoulder and hip only, no visible elbow or knee. Mandatory floating holographic cyan "
        "wireframe notebook hovering beside the right shoulder. Upright balanced posture, 8-degree "
        "forward head tilt, gentle encouraging expression with a soft upward eye crescent. Premium "
        "stylized mascot illustration rendering, smooth gradient shading, soft restrained specular "
        "highlights, clean rounded outlines, simple uncluttered background, soft studio lighting "
        "from upper-left, gentle rim light along the shell edge, warm and trustworthy atmosphere."
    ),
    "negativePrompt": (
        "No visor-band eyes, no rectangular screen face, no single cyclops eye, no angular or "
        "triangular eyes; the eye system must remain twin round LED-matrix eyes only. No visible "
        "neck, no elongated legs, no long agile limbs, no athletic V-shaped torso. No removal of "
        "the holographic notebook accessory. No orange, red, purple, or graphite color substitutions "
        "for the primary/secondary palette. No visible bolts, screws, rivets, exposed wiring, or "
        "industrial panel seams. No photorealistic metal textures, no military or combat mecha "
        "styling, no dystopian or rusted machinery, no aggressive body language, no frightening "
        "facial expressions. No asymmetrical body construction, no duplicated or missing limbs, "
        "no malformed hands or incorrect finger counts, no distorted or stretched silhouette, no "
        "oversized or undersized head relative to the 1:1.6 ratio. No dark cinematic color grading, "
        "no gritty or blurry rendering, no low-resolution artifacts, no watermarks, signatures, "
        "logos, or text overlays, no cluttered or noisy background, no overexposed or oversaturated "
        "lighting, no inconsistent illumination between body segments."
    ),
    "masterPrompt": (
        "MASTER PRODUCTION BLUEPRINT — NOVA-BOT. Conceptual foundation: Nova-Bot exists to make "
        "artificial intelligence feel safe, patient, and trustworthy to learners of every age. "
        "The entire design vocabulary is built around softness and openness rather than "
        "technological spectacle, because the platform's educational mission depends on learners "
        "feeling comfortable rather than intimidated. Visual hierarchy: the eyes are read first "
        "because they are the largest, brightest, highest-contrast elements on the face; the "
        "overall egg silhouette is read second because it is instantly identifiable even in "
        "silhouette form; the holographic notebook is read third as the functional identity "
        "marker; the antenna crystal is read fourth as a small symbolic accent. Construction "
        "methodology: the body is a single tapered capsule primitive with no neck break, which "
        "keeps the silhouette calm and non-threatening; limbs are short stub cylinders with only "
        "one ball-joint each, reducing visual complexity and reinforcing a toy-like approachability. "
        "Materials exist for narrative reasons: the satin white shell communicates cleanliness and "
        "safety, the polycarbonate joint sleeves communicate gentle premium engineering, and the "
        "cyan chest lens and antenna crystal communicate the presence of active, benevolent "
        "intelligence. Color psychology: white for safety and clarity, sky blue for calm trust, "
        "glow cyan for active insight, amber reserved exclusively for rare attention cues so it "
        "never dilutes the calm palette. Camera and composition guidance: Nova-Bot reads best in "
        "a three-quarter view with the head and eyes clearly visible; for icon and sticker "
        "compatibility, keep the notebook fully inside frame since it is a mandatory identity "
        "marker; for portrait and avatar crops, the head and top of the torso alone remain fully "
        "recognizable due to the eye system; for full-body illustrations, preserve the 1:1.6 "
        "head-to-body ratio at all times. Recommended poses: a gentle forward-leaning explaining "
        "pose for onboarding tutorials, an upward-crescent encouraging pose for achievement badges, "
        "a wide-eyed curious pose for discovery-themed marketing, and a calm centered pose for "
        "splash screens. Consistency manifesto: the rounded egg silhouette, the twin round "
        "LED-matrix eyes at their specified proportions, the satin white and sky blue palette, "
        "the single looped antenna with glowing crystal tip, and the mandatory holographic "
        "notebook must remain identical across every future illustration regardless of rendering "
        "engine, art style, lighting condition, or camera angle. Pose, background, expression "
        "state, and camera framing may change freely. Any generation that alters the eye system, "
        "removes the notebook, or shifts the palette toward orange, red, or industrial tones "
        "should be treated as an identity-drift failure and regenerated against this document."
    )
}
characters.append(nova)

# ------------------------------------------------------------------
# 2. ORBIT
# ------------------------------------------------------------------
orbit = {
    "name": "Orbit",
    "category": "Interstellar Courier Robot",
    "description": (
        "Orbit is the platform's dedicated logistics mascot: an aerodynamic, forward-leaning "
        "courier robot built for speed and dependability, identified by a single horizontal "
        "visor-band eye strip, twin rear-swept fin antennae, and a mandatory shoulder-mounted "
        "parcel pod. Its visual language communicates reliable, confident motion rather than "
        "the calm stillness of Nova-Bot."
    ),
    "promptConsistency": (
        "Immutable markers: (1) forward-leaning torso silhouette at a 12-degree lean with a "
        "slim tapered waist, entirely distinct from Nova-Bot's egg shape; (2) single horizontal "
        "visor-band LED eye strip spanning 70% of head width, no round pupils, color shifts "
        "between orange (#FF6F00, active delivery) and cyan (#00B8D4, idle/navigating); (3) "
        "gloss white/silver shell (#ECEFF1) with deep space navy panels (#1A237E); (4) twin "
        "rear-swept fin antennae tipped with small orange nav-lights; (5) mandatory rounded "
        "hexagonal shoulder-mounted parcel pod with orange trim; (6) longer digitigrade-style "
        "legs (30% of total height) with twin calf-mounted micro-thrusters and a backpack "
        "propulsion pack. Flexible: pose, flight vs. ground stance, background, delivery cargo "
        "type. Never give Orbit round LED eyes, never remove the parcel pod, never shorten the "
        "legs to Nova-Bot proportions."
    ),
    "bible": {
        "immutableIdentity": {
            "role": "Primary interstellar logistics and delivery mascot of the platform",
            "emotionalPurpose": "Communicate speed, reliability, and dependable service",
            "audience": "Users of logistics-themed, delivery-themed, or exploration-adjacent product surfaces",
            "communicationObjective": "Instant recognition as an agile, dependable courier ready for the next mission",
            "designPhilosophy": "Aerodynamic lean, athletic proportions, visor-based readout instead of expressive round eyes",
            "personalityKeywords": ["fast", "reliable", "responsible", "confident", "warm", "efficient"],
            "symbolicMeaning": "The parcel pod represents a promise kept; the visor strip represents forward focus on the next destination",
            "brandingRole": "Used for logistics, scheduling, delivery-tracking, and mission-themed illustrations",
            "permanentVsContextual": "Silhouette lean, visor eye system, palette, parcel pod, and thruster pack are permanent. Cargo type, flight vs. ground pose, and background are contextual."
        },
        "silhouetteAndProportions": {
            "silhouetteDescription": "Forward-leaning tapered torso above longer digitigrade legs, twin rear fin antennae, backpack propulsion pack breaking the rear silhouette line — unmistakably distinct from Nova-Bot's unbroken egg shape",
            "totalHeightReference": "34 cm mascot scale",
            "headToBodyRatio": "1:2.2 (smaller head relative to body than Nova-Bot)",
            "torsoLean": "12-degree forward lean from vertical",
            "legLength": "30% of total height, digitigrade-style lower leg for an agile stance",
            "armLength": "40% of torso height, ending in four-fingered gloved hands for parcel handling",
            "shoulderWidth": "moderately broad, tapering to a slim waist",
            "postureStance": "weight forward on the balls of the feet, perpetually ready to launch"
        },
        "structuralConstruction": {
            "bodyGeometry": "Tapered cone-like torso narrowing toward the waist, cylindrical limbs, wedge-shaped head with a flat visor face",
            "jointArticulation": "Visible shoulder ball-joints, hinged elbows, hinged knees with segmented thigh/calf panels for agile movement",
            "panelSegmentation": "Chest plate split into two symmetric panels with a central seam housing the communication antenna base; calf panels segmented to expose micro-thruster housings",
            "mechanicalDetailing": "Twin calf-mounted micro-thrusters, backpack propulsion pack with twin exhaust vents, wrist-mounted route-map projector port, chest-mounted communication antenna base, visible maintenance panel on the lower back"
        },
        "headAndFace": {
            "headConstruction": "Wedge-shaped head tapering slightly forward, flat front visor face, no separate jaw or cheek forms",
            "eyeSystem": {
                "type": "single horizontal visor-band LED strip",
                "width": "70% of head width",
                "segments": "5 animated brightness segments used to indicate status pulses",
                "colorStates": {"activeDelivery": "#FF6F00", "idleNavigating": "#00B8D4"},
                "emotionMapping": {
                    "confidence": "steady full-brightness strip",
                    "urgency": "fast segment-chase animation left to right",
                    "calm": "slow uniform pulse",
                    "alert": "strip flashes twice at full brightness"
                }
            },
            "mouthOrExpressionSystem": "No physical mouth or secondary display; all emotional communication routes through the visor strip's color, brightness, and animation pattern"
        },
        "materials": [
            {"component": "shoulder plates", "material": "brushed aluminum", "finish": "satin metallic, moderate reflectivity"},
            {"component": "torso shell", "material": "matte painted navy composite", "finish": "low reflectivity, durable travel-ready finish"},
            {"component": "limb shells", "material": "glossy white polycarbonate", "finish": "high gloss, clean premium look"},
            {"component": "grip padding at hands/boots", "material": "rubberized orange silicone", "finish": "matte, textured for grip"},
            {"component": "thruster housings", "material": "transparent acrylic", "finish": "glows cyan when active, clear when idle"}
        ],
        "colorSystem": {
            "primary": {"name": "Gloss White/Silver", "hex": "#ECEFF1", "psychology": "cleanliness and dependable premium service"},
            "secondary": {"name": "Deep Space Navy", "hex": "#1A237E", "psychology": "reliability, professionalism, vastness of space travel"},
            "accent": {"name": "Energetic Orange", "hex": "#FF6F00", "psychology": "urgency, active task status, warmth"},
            "navigation": {"name": "Navigation Cyan", "hex": "#00B8D4", "psychology": "calm wayfinding, idle readiness"},
            "neutral": {"name": "Panel Grey", "hex": "#CFD8DC", "psychology": "understated seams and trims"}
        },
        "lightingBehavior": {
            "glowSources": ["visor strip", "nav-lights on antenna fins", "thruster housings"],
            "bloomIntensity": "moderate, slightly stronger than Nova-Bot to communicate active energy",
            "daylight": "gloss shell produces crisp specular highlights along the torso taper",
            "studioLighting": "strong rim light along the aerodynamic edges to emphasize motion-readiness",
            "sunset": "orange ambient light harmonizes naturally with the accent palette",
            "backlighting": "visor strip and thruster glow punch through strongly, silhouette reads as forward-leaning and dynamic"
        },
        "accessories": [
            {
                "name": "Shoulder-Mounted Parcel Pod",
                "mandatory": True,
                "purpose": "Represents Orbit's core delivery function",
                "construction": "Rounded hexagonal container with orange trim and a holographic address label",
                "attachment": "Strapped across the back via a padded harness",
                "material": "Matte composite shell with a glowing orange edge trim"
            },
            {
                "name": "Wrist-Mounted Route-Map Projector",
                "mandatory": True,
                "purpose": "Represents navigation and logistics planning",
                "construction": "Small cyan holographic map projected from a wrist-mounted emitter",
                "attachment": "Fixed to the left wrist",
                "material": "Volumetric holographic projection"
            }
        ],
        "movementLanguage": {
            "idleAnimation": "subtle thruster flicker, weight rocking slightly forward and back",
            "walkCycle": "long confident strides with a slight forward lean",
            "flightHover": "graceful hovering with visible thruster glow, controlled acceleration and smooth landings",
            "turning": "efficient banking turn with visor strip brightening on the turn direction",
            "restrictedMotion": "never appears sluggish or hesitant; always reads as mission-ready"
        },
        "renderingStyle": {
            "styleDirection": "premium mascot illustration with slightly more dynamic energy lines than Nova-Bot, still avoiding photorealism",
            "lineQuality": "clean aerodynamic edges with slightly sharper contour lines than Nova-Bot",
            "shading": "gradient shading with stronger directional highlights to emphasize motion",
            "specularHighlights": "crisp and moderately bright along gloss surfaces"
        },
        "environmentCompatibility": {
            "ideal": ["space travel scenes", "logistics dashboards", "delivery-tracking interfaces", "mission-themed marketing"],
            "acceptable": ["cityscapes", "presentation slides", "onboarding screens for logistics products"],
            "avoid": ["static classroom-only settings that contradict its motion-forward identity", "combat or military environments"]
        },
        "consistencyRules": {
            "immutable": [
                "forward-leaning tapered silhouette with digitigrade legs",
                "single horizontal visor-band LED eye strip",
                "gloss white/silver shell with deep space navy panels",
                "twin rear-swept fin antennae with orange nav-lights",
                "mandatory shoulder-mounted parcel pod",
                "backpack propulsion pack with twin exhaust vents"
            ],
            "flexible": ["flight vs. ground pose", "cargo type in the parcel pod", "background", "camera angle"],
            "commonMistakes": [
                "AI models giving Orbit round expressive eyes instead of the visor strip",
                "AI models removing the parcel pod or thruster pack",
                "AI models shortening the legs to compact proportions",
                "AI models applying a matte white/blue palette identical to Nova-Bot"
            ],
            "antiDriftStrategies": [
                "always restate the visor-strip eye system before pose description",
                "always restate the mandatory parcel pod and thruster pack",
                "explicitly negative-prompt against round LED eyes",
                "restate the 12-degree forward lean in every prompt"
            ]
        }
    },
    "positivePrompt": (
        "Orbit, an aerodynamic interstellar courier robot mascot with a forward-leaning torso at "
        "a 12-degree lean and a slim tapered waist above longer digitigrade legs. Wedge-shaped "
        "head with a single horizontal visor-band LED eye strip spanning 70% of head width, no "
        "round pupils, glowing orange (#FF6F00) when actively delivering or cyan (#00B8D4) when "
        "idle and navigating. Gloss white/silver polycarbonate limb shells (#ECEFF1), matte "
        "painted deep-space-navy torso shell (#1A237E), brushed aluminum shoulder plates, "
        "rubberized orange grip padding at hands and boot soles. Twin rear-swept fin antennae "
        "flanking the head, each tipped with a small glowing orange nav-light. Backpack propulsion "
        "pack with twin exhaust vents glowing cyan, twin calf-mounted micro-thrusters. Mandatory "
        "rounded hexagonal shoulder-mounted parcel pod with orange trim and a holographic address "
        "label, wrist-mounted cyan holographic route-map projector on the left wrist. Confident "
        "forward-leaning stance with weight on the balls of the feet, ready-to-launch posture. "
        "Premium stylized mascot illustration rendering, crisp aerodynamic contour lines, gradient "
        "shading with strong directional highlights, clean simple background, dynamic rim lighting "
        "along the edges suggesting motion, energetic and dependable atmosphere."
    ),
    "negativePrompt": (
        "No round LED-matrix eyes, no digital pixel-grid face, no cyclops telescope eye, no "
        "angular lightning-shaped eyes; the eye system must remain a single horizontal visor-band "
        "strip only. No compact egg-shaped torso, no unbroken capsule silhouette, no short stub "
        "legs. No removal of the shoulder-mounted parcel pod, no removal of the backpack propulsion "
        "pack or calf thrusters. No white-and-sky-blue palette identical to other mascots in the "
        "collection, no substitution of the navy/orange/cyan palette with graphite, yellow, or "
        "purple tones. No visible bolts, screws, or exposed wiring beyond the documented thruster "
        "housings. No photorealistic industrial robot textures, no military mecha styling, no "
        "dystopian rust or damage, no aggressive weaponry. No asymmetrical limbs, no duplicated or "
        "missing limbs, no malformed hands, no distorted or stretched silhouette, no incorrect "
        "head-to-body ratio. No static or sluggish posture that contradicts the forward-leaning "
        "ready stance. No dark cinematic grading, no blurry or low-resolution rendering, no "
        "watermarks, signatures, logos, or text overlays, no cluttered background, no overexposed "
        "or oversaturated lighting, no inconsistent illumination across body segments."
    ),
    "masterPrompt": (
        "MASTER PRODUCTION BLUEPRINT — ORBIT. Conceptual foundation: Orbit exists to embody "
        "dependable motion across the platform's logistics and exploration surfaces. Every "
        "design decision reinforces forward momentum and reliability rather than the calm "
        "stillness associated with Nova-Bot. Visual hierarchy: the visor-band eye strip is read "
        "first because it is the highest-contrast horizontal element on the head; the "
        "forward-leaning silhouette is read second because the 12-degree lean is instantly "
        "perceivable even in a static frame; the shoulder-mounted parcel pod is read third as "
        "the functional identity marker; the rear fin antennae and thruster glow are read fourth "
        "as motion-reinforcing accents. Construction methodology: the tapered torso and "
        "digitigrade legs follow a believable aerodynamic engineering logic, with segmented calf "
        "panels exposing micro-thruster housings that justify the character's speed narrative. "
        "Materials exist for narrative reasons: brushed aluminum shoulder plates communicate "
        "durable travel-grade construction, matte navy torso communicates professional reliability, "
        "gloss white limbs communicate a clean premium delivery service, and rubberized orange "
        "grip padding communicates practical, hands-on functionality. Color psychology: white/silver "
        "for cleanliness and premium service, deep space navy for reliability and professionalism, "
        "energetic orange for active task urgency, navigation cyan for calm idle wayfinding. Camera "
        "and composition guidance: Orbit reads best in a three-quarter dynamic angle that shows both "
        "the forward lean and the parcel pod; for icon and sticker compatibility, ensure the visor "
        "strip and parcel pod remain within frame since both are mandatory identity markers; for "
        "portrait crops, the head and shoulder-pod region alone remain recognizable; for full-body "
        "illustrations, preserve the 12-degree lean and 1:2.2 head-to-body ratio at all times. "
        "Recommended poses: a hovering flight pose with thruster glow for mission-themed marketing, "
        "a confident ground-stance for onboarding screens, a route-checking pose referencing the "
        "wrist projector for logistics dashboards, and a landing-crouch pose for achievement badges. "
        "Consistency manifesto: the forward-leaning tapered silhouette, the single horizontal "
        "visor-band eye strip, the white/navy/orange/cyan palette, the twin rear-swept fin "
        "antennae, and the mandatory parcel pod and thruster pack must remain identical across "
        "every future illustration regardless of rendering engine, art style, lighting condition, "
        "or camera angle. Flight vs. ground pose, cargo contents, and background may change freely. "
        "Any generation that gives Orbit round expressive eyes, removes the parcel pod, or "
        "compresses the silhouette toward Nova-Bot's proportions should be treated as an "
        "identity-drift failure and regenerated against this document."
    )
}
characters.append(orbit)

print("Nova-Bot and Orbit built OK")
print(len(json.dumps(nova["bible"])), len(json.dumps(orbit["bible"])))
