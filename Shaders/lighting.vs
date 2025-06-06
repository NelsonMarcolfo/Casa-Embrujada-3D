#version 330 core
struct Material
{
    sampler2D diffuse;
    sampler2D specular;
    float       shininess;
};


struct Light
{
    vec3 position;
    vec3 direction;
    float cutOff;
    float outerCutOff;
    
    float constant;
    float linear;
    float quadratic;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};


in vec3 FragPos;
in vec3 Normal;
in vec2 TexCoords;


out vec4 color;


uniform vec3 viewPos;
uniform Material material;
uniform Light light;
uniform bool flashlightIsActive; // Nueva uniform para controlar la luz


void main()
{
    // Calculate the vector from the fragment position to the light source
    vec3 lightDir = normalize(light.position - FragPos);
    // Calculate the cosine of the angle between the fragment's direction and the light's direction
    float theta = dot(lightDir, normalize(-light.direction));


    // Calculate the spotlight intensity using smoothstep for a soft edge
    float intensity = smoothstep(light.outerCutOff, light.cutOff, theta);


    // If the flashlight is not active or the fragment is outside the outer cone, the intensity is zero
    if (!flashlightIsActive || theta < light.outerCutOff) {
        intensity = 0.0;
    }


    // Base grayscale value (very dark ambient)
    float grayscaleValue = 0.05;


    // If inside the spotlight cone, apply a brighter grayscale
    if (intensity > 0.0) {
        // Use the intensity to modulate the brightness within the cone
        grayscaleValue = 0.3 + 0.7 * intensity; // Adjust these values to control brightness
    }


    // Final grayscale color
    vec3 finalColor = vec3(grayscaleValue);
    color = vec4(finalColor, 1.0f);
}
