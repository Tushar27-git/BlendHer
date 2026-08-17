<div align="center">

# ✨ BlendHer — Cinematic Hybrid Minecraft Shaderpack

### *A Dual-Soul Visual Shader Fusing Warm BSL Golden Sunlight with Chilling Spooklementary Horror Atmosphere*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Iris%20%7C%20Oculus%20%7C%20OptiFine-8A2BE2?style=for-the-badge)](https://modrinth.com/mod/iris)
[![OpenGL](https://img.shields.io/badge/GLSL-1.50%20%2F%20OpenGL%203.0%2B-555555?style=for-the-badge&logo=opengl&logoColor=white)](https://www.khronos.org/opengl/)
[![Distant Horizons](https://img.shields.io/badge/LOD-Distant%20Horizons%20Ready-008080?style=for-the-badge)](https://modrinth.com/mod/distant-horizons)
[![Performance](https://img.shields.io/badge/Target-60%2B%20FPS%20Optimized-success?style=for-the-badge)](https://github.com/Tushar27-git/BlendHer)

<p align="center">
  <strong>BlendHer</strong> is a custom GLSL shaderpack for Minecraft that seamlessly blends rich golden-hour illumination with desaturated, atmospheric horror shadows — delivering stunning visuals with lightweight, high-performance rendering.
</p>

---

</div>

## 🌌 About the Shaderpack

**BlendHer** bridges two distinct visual aesthetics: the warm, vibrant, and inviting illumination of **BSL Shaders**, and the eerie, desaturated, suspense-filled atmosphere of **Spooklementary**. 

Instead of a static filter, BlendHer uses a **branchless dynamic lighting engine** that crossfades between warm golden radiance in lit spaces (torches, sunlight) and cold, desaturated olive-purple shadows in caves and dark environments. Designed from the ground up for maximum visual fidelity without the heavy performance penalty of full path-tracing, BlendHer runs smoothly across a wide range of hardware.

---

## 🎨 What Has Been Implemented

### 1. 🌓 Dual-Soul Branchless Lighting Engine (`lighting.glsl`)
- **BSL-Mode (Lit Areas)**: Saturated, warm golden lighting (`RGB: 1.05, 0.98, 0.88`) near torches, campfires, and direct sun.
- **Spook-Mode (Shadow Areas)**: Desaturated olive-purple shadow tones with subtle chromatic shifts in low-light environments.
- **Branchless Crossfade**: Employs `smoothstep` blending without GPU warp divergence (`if/else` branching) to seamlessly transition lighting modes.
- **Additive Purple Ambient Floor**: Adds a gentle ambient baseline (`RGB: 0.04, 0.03, 0.09`) to prevent dark caves from collapsing into unplayable pitch black while preserving a moody horror atmosphere.
- **Half-Lambert Diffuse**: Softens the terminator line on blocks for smooth, organic light wrapping.
- **Cyan Moonlight Cycle**: Dynamically tints nighttime landscapes with cool cyan hues based on world time.

---

### 2. 🌊 Realistic Water & Fluid Mechanics (`water.glsl`, `gbuffers_water.*`)
- **Dual-Layer Gerstner Waves**: 3D circular arc vertex displacement and surface normal calculation creating organic, non-repeating wave crests and flat troughs.
- **Beer-Lambert Wavelength Absorption**: Physics-accurate water depth attenuation where red wavelengths absorb first, giving shallow water crystal clarity and deep oceans a rich teal-blue gradient.
- **Screen-Space Reflections (SSR)**: Raymarched view-space water surface reflections with edge fading to eliminate harsh screen-border artifacts.
- **Chromatic Aberration**: Simulates optical lens distortion with subtle RGB fringe splitting at screen edges when viewing water.
- **Midnight Mirror Darkening**: Water surfaces transition into reflective teal-black mirrors under moonlight.

---

### 3. 🌿 Dynamic Foliage Wind & Ground-Lock Math (`displacement.glsl`, `gbuffers_terrain.vsh`)
- **Multi-Axis Sine Wind Displacement**: Distinct sway frequencies and amplitudes for tall grass, tree leaves, and agricultural crops.
- **Vertex-Stage Ground Locking**: Uses UV coordinate thresholds (`1.0 - step(0.5, vaUV0.y)`) to anchor plant roots securely to the ground while allowing tips to sway naturally.
- **Storm Reactivity**: Automatically scales wind displacement amplitude by **1.8×** during rain and thunderstorms.

---

### 4. ☀️ Shadows, God Rays & Atmosphere (`shadow.glsl`, `atmosphere.glsl`, `composite.fsh`)
- **Cosine-Distorted Shadow Mapping (2048×2048)**: Allocates 90% of shadow map resolution to near-player geometry for razor-sharp close-up shadows.
- **3×3 PCF (Percentage-Closer Filtering)**: Softens shadow penumbras with normal-offset biasing to eliminate shadow acne.
- **Radial Screen-Space God Rays**: Lightweight crepuscular sun shafts with exponential decay gating (zero performance cost compared to heavy volumetric marching).
- **Atmospheric & Distant Horizons Fog**: Exponential sky-derived haze with purple color shifting and a smooth 300-block transition zone for the **Distant Horizons** LOD mod.
- **Rain Scene Desaturation**: Drains world saturation during rain without reducing view distance below 32 blocks.

---

### 5. 🌸 Post-Processing & Tone-Mapping (`tonemapping.glsl`, `composite1.fsh`, `composite2.fsh`, `final.fsh`)
- **ACES Filmic Tone-Mapping**: Transforms HDR render buffers to sRGB color space via an optimized ACES curve.
- **Horror Shadow Crush**: Applies non-linear exponential power (`pow(x, 1.15)`) to selectively deepen dark areas without clipping bright highlights.
- **Separable 2-Pass Gaussian Bloom**: Two-pass (horizontal + vertical) 1D Gaussian blur with a bright-pass luminance threshold (`1.2`) and 15-sample kernel for glowing emissives and torches.

---

## 🗂️ Shaderpack Architecture & Pipeline

```
BlendHer Pipeline Flow
├── GBuffer Passes (Geometry & Material Data)
│   ├── gbuffers_terrain.*       -> Albedo, world normals, lightmap RG (colortex0, colortex1, colortex3)
│   ├── gbuffers_water.*         -> Water absorption, Gerstner normals, SSR flags (colortex2.g = 1.0)
│   ├── gbuffers_entities.*      -> Mob and player entity rendering with lightmap support
│   └── gbuffers_textured.*      -> UI and particles pass-through
├── Shadow Pass
│   └── shadow.*                 -> Cosine-distorted shadow depth map (shadowtex0)
├── Composite Passes (Deferred Shading)
│   ├── composite.fsh            -> BSL/Spook lighting, PCF shadows, SSR, God Rays, DH Fog, ACES Tonemap
│   ├── composite1.fsh           -> Bloom Pass 1: Horizontal Gaussian blur on bright-pass pixels
│   └── composite2.fsh           -> Bloom Pass 2: Vertical Gaussian blur + additive blend onto scene
└── Final Pass
    └── final.fsh                -> Display output buffer (colortex0 -> monitor)
```

---

## ⚙️ In-Game Configuration & Settings

All core parameters can be tuned in `shaders/include/settings.glsl` or via the in-game shader settings menu (`en_US.lang`):

| Setting | Default | Range / Options | Description |
| :--- | :--- | :--- | :--- |
| `SHADOW_RESOLUTION` | `2048` | `512 – 4096` | Shadow map texture resolution (2048 = ~8MB VRAM) |
| `SHADOW_DISTANCE` | `128.0` | `64.0 – 256.0` | Maximum distance shadows are cast from player |
| `BLOOM_STRENGTH` | `0.35` | `0.0 – 1.0` | Intensity of glowing emissives and light sources |
| `SSR_STEPS` | `16` | `8 – 32` | Raymarching sample count for water reflections |
| `GODRAY_SAMPLES` | `8` | `4 – 16` | Radial screen-space sun shaft sample density |
| `AMBIENT_THRESHOLD` | `0.05` | `0.01 – 0.20` | Light level threshold triggering Spook horror desaturation |
| `FOG_DENSITY` | `0.0005` | `0.0001 – 0.002` | Atmospheric distance fog density |
| `WIND_GRASS_AMP` | `0.15` | `0.0 – 0.50` | Amplitude of grass and foliage wind sway |

---

## 🚀 Installation & Usage

### 📋 Requirements
- **Minecraft**: 1.16.5 – 1.21+ (Fabric / Forge / NeoForge)
- **Shader Loader**: [Iris Shaders](https://modrinth.com/mod/iris) *(Recommended)*, [Oculus](https://curseforge.com/minecraft/mc-mods/oculus), or [OptiFine](https://optifine.net/)
- **Optional**: [Distant Horizons](https://modrinth.com/mod/distant-horizons) (Full LOD fog integration supported)

### 📥 How to Install
1. Download the latest `BlendHer_fixed2.zip` from this repository or clone it:
   ```bash
   git clone https://github.com/Tushar27-git/BlendHer.git
   ```
2. Copy `BlendHer_fixed2.zip` (or the `shaders/` folder inside a `.zip`) into your Minecraft shaderpacks directory:
   - **Windows**: `%appdata%\.minecraft\shaderpacks\`
   - **macOS**: `~/Library/Application Support/minecraft/shaderpacks/`
   - **Linux**: `~/.minecraft/shaderpacks/`
3. Launch Minecraft, go to **Options → Video Settings → Shader Packs**, select **BlendHer**, and apply!

---

## 🗂️ Project Directory Structure

```
BlendHer/
├── BlendHer_fixed2.zip          # Production-ready shaderpack archive
├── LICENSE                      # MIT License
├── README.md                    # Project documentation
└── shaders/                     # GLSL Shader Source Files
    ├── composite.fsh            # Main deferred shading & lighting pass
    ├── composite1.fsh           # Horizontal Gaussian bloom pass
    ├── composite2.fsh           # Vertical Gaussian bloom + composite pass
    ├── final.fsh                # Screen display output pass
    ├── gbuffers_entities.fsh/vsh# Entity rendering shaders
    ├── gbuffers_skytextured.*   # Sky texture pass
    ├── gbuffers_terrain.fsh/vsh # Terrain, blocks, and foliage shaders
    ├── gbuffers_textured.*      # Particles and textured quads
    ├── gbuffers_water.fsh/vsh   # Water, stained glass, and fluids
    ├── shadow.fsh/vsh           # Shadow map generation
    ├── shaders.properties       # Texture attachments & block ID mappings
    ├── include/                 # Modular GLSL logic headers
    │   ├── atmosphere.glsl      # Atmospheric fog, DH fog wall, rain desaturation
    │   ├── displacement.glsl    # Wind sway math & vertex ground locking
    │   ├── lighting.glsl        # BSL/Spook branchless lighting crossfade
    │   ├── pbr.glsl             # Screen-space reflections (SSR)
    │   ├── settings.glsl        # Shader constants, presets, and configuration
    │   ├── shadow.glsl          # PCF shadow filtering, distortion, and god rays
    │   ├── tonemapping.glsl     # ACES filmic curve & horror shadow crush
    │   ├── uniforms.glsl        # Engine uniforms & camera projection matrices
    │   ├── utils.glsl           # Color conversion & luma helper functions
    │   └── water.glsl           # Gerstner waves & Beer-Lambert absorption
    └── lang/
        └── en_US.lang           # In-game settings localization dictionary
```

---

## 📄 License

This shaderpack is distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

---

<div align="center">
  <sub>Crafted with ❤️ for the Minecraft shader and modding community.</sub>
</div>
