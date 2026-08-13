# Flexus Games — Graphics Programmer Test Task

Test assignment implemented in **Unity 6000.3.8f1**.

The project demonstrates procedural vertex displacement, interactive RenderTexture painting, damped oscillation and a custom chameleon material.

## Features

### LVL 1 — Chameleon Material

Custom shader implementing:

- Fresnel-based transition between two configurable colors
- Specular lighting
- Metallic lighting mode
- Cubemap reflections
- Configurable colors, smoothness and metallic parameters
- Adjustable reflection strength
- Runtime shader keyword switch between Specular and Metallic lighting modes

### LVL 2 — Perlin Noise Displacement

Procedural plane displacement using fractal Perlin noise.

Configurable parameters:

- Base frequency
- Octaves
- Lacunarity
- Persistence
- Noise amplitude
- Noise speed

Vertex normals are recalculated after displacement using finite differences.

### LVL 3–4 — Interactive Texture Painting, Oscillation and Damping

Mouse input is used to paint into a RenderTexture.

The brush creates:

- Depression inside the brush radius
- Raised ring outside the brush radius

The resulting texture is used as a displacement map.

Each texel stores:

- **R** — displacement height
- **G** — vertical velocity

The painted displacement oscillates independently at each texel and gradually returns to equilibrium.

Configurable parameters:

- Brush radius and strength
- Ring radius and strength
- Oscillation frequency
- Oscillation damping

The simulation state is updated using a ping-pong RenderTexture approach with one additional Render Target switch per frame.

### LVL 5 — Combined Effect

Final shader combines:

- Perlin noise displacement
- Interactive painted displacement
- Oscillation and damping
- Recalculated surface normals
- Chameleon material
- Specular / Metallic lighting
- Cubemap reflections
- Wave-dependent color

Wave velocity stored in the RenderTexture is used to modify the surface color while the displacement is moving.

## Controls

**Left Mouse Button** — interact with the surface.

## Technical Notes

The fluid state is stored in an `RGHalf` RenderTexture.

A ping-pong RenderTexture setup is used to update the simulation state without CPU texture readback.

Surface displacement and normals are calculated on the GPU.

## Unity Version

**Unity 6000.3.8f1**
