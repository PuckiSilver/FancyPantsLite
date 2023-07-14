#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0; // fancy pants lite
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec4 normal;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    // fancy pants lite
    if (texelFetch(Sampler0, ivec2(0, 1), 0) == vec4(1)) { // is custom leather layer
        ivec2 size = textureSize(Sampler0, 0);
        vec2 armor_size = vec2(64. / size.x, 32. / size.y);
        texCoord0 *= armor_size;
        texCoord1 *= armor_size;

        for (int i = 0; i < size.y / 32. + 0.5; i++) {
            for (int j = 0; j < size.x / 64. + 0.5; j++) {
                if (texelFetch(Sampler0, ivec2(j*64, i*32), 0) == Color) {
                    texCoord0 += armor_size * ivec2(j, i);
                    texCoord1 += armor_size * ivec2(j, i);
                    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1)) * texelFetch(Sampler2, UV2 / 16, 0);
                    break;
                }
            }
        }
    }
}
