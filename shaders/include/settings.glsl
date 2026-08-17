// ============================================================
// BLENDHER -------- settings.glsl
// Format: #define NAME value // default | range | perf impact
// ============================================================

// -------------- SHADOW -------------------------------------------------------
#define SHADOW_RESOLUTION 2048 // 2048 | 512-4096 | 2048=8MB VRAM
#define SHADOW_DISTANCE   128.0 // 128 | 64-256 | linear cost
#define SHADOW_NORMAL_OFFSET 0.02 // 0.02 | 0.01-0.05 | acne fix
#define SHADOW_DISTORTION 0.9  // 0.9 | 0.7-1.0 | pinch factor

// -------------- AMBIENT / PURPLE FLOOR ---------------------------------------
#define AMBIENT_R 0.04
#define AMBIENT_G 0.03
#define AMBIENT_B 0.09
#define AMBIENT_THRESHOLD   0.05  // Spook-Mode below this light level
#define AMBIENT_BLEND_WIDTH 0.10  // smoothstep crossfade width
#define SPOOK_DESAT         0.55  // shadow desaturation amount | 0-1

// -------------- BSL WARMTH (DAYLIGHT/TORCH) ----------------------------------
#define BSL_WARMTH_R 1.05
#define BSL_WARMTH_G 0.98
#define BSL_WARMTH_B 0.88

// -------------- MOONLIGHT (NIGHT MODE) ---------------------------------------
#define MOON_CYAN_R   0.72
#define MOON_CYAN_G   0.88
#define MOON_CYAN_B   1.00
#define MOON_INTENSITY 0.18

// -------------- TONE-MAPPING -------------------------------------------------
#define HORROR_SHADOW_CRUSH 1.15

// -------------- BLOOM --------------------------------------------------------
#define BLOOM_THRESHOLD 1.2
#define BLOOM_RADIUS    7.0
#define BLOOM_STRENGTH  0.35

// -------------- WATER --------------------------------------------------------
#define WATER_REFRACTION_IOR 1.33
#define WATER_CHROMA_ABERR   0.02
#define WATER_ABSORB_R       0.02
#define WATER_ABSORB_G       0.05
#define WATER_ABSORB_B       0.10
#define WATER_REFLECT_STRENGTH 0.8
#define WATER_WAVE_FREQ      0.25
#define WATER_WAVE_AMP       0.10
#define WATER_NIGHT_DARKEN   0.55

// -------------- ATMOSPHERE ---------------------------------------------------
#define FOG_START      64.0
#define FOG_DENSITY    0.0005
#define FOG_DH_START   1200.0
#define FOG_DH_END     1500.0
#define FOG_SAT_REDUCE 0.15
#define FOG_PURPLE_SHIFT 0.05
#define RAIN_DESAT     0.75

// -------------- FOLIAGE WIND -------------------------------------------------
#define WIND_GRASS_FREQ  2.0
#define WIND_GRASS_AMP   0.15
#define WIND_LEAVES_FREQ 0.8
#define WIND_LEAVES_AMP  0.05
#define WIND_CROPS_FREQ  3.0
#define WIND_CROPS_AMP   0.08
#define RAIN_WIND_MULT   1.8

// -------------- GOD RAYS -----------------------------------------------------
#define GODRAY_SAMPLES  8
#define GODRAY_STRENGTH 0.4
#define GODRAY_DECAY    0.96

// -------------- SSR ----------------------------------------------------------
#define SSR_STEPS     16
#define SSR_THICKNESS 0.5
