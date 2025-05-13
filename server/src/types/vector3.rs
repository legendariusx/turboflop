use spacetimedb::{SpacetimeType};

#[derive(SpacetimeType, Debug, Clone, Copy)]
pub struct Vector3 {
    pub x: f32,
    pub y: f32,
    pub z: f32,
}