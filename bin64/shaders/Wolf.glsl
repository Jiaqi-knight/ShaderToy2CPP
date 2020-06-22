#version 330 core
uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds)
uniform float     iTimeDelta;            // render time (in seconds)
uniform int       iFrame;                // shader playback frame
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform vec4	  iMouseSpeed;           // mouse speed

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;

#define R iResolution.xy
#define pixel(ch, p) texture(ch,(p)/R)
#define ch0 iChannel0
#define ch1 iChannel1
#define PI 3.14159265

vec4 removewhite(vec4 c)
{
	float d = distance(c.xyz, vec3(1.)); //distance to white 
	return step(0.5, d)*c; 
}

float kernel(vec2 dx)
{
	return exp(-dot(dx,dx));
}

void mainImage( out vec4 O, in vec2 P )
{
	vec2 wolf_size = textureSize(ch0, 0);
	vec2 wolf_center = R*vec2(0.5, 2.5);
	float wolf_scale = 1.;
	vec2 wolf_world_size = wolf_size*wolf_scale;
	vec2 sampling_pos = clamp((P - (wolf_center - wolf_world_size*0.5))/wolf_world_size, vec2(0.), vec2(1.));
	sampling_pos = vec2(sampling_pos.x, 1. - sampling_pos.y);
	vec4 eyes = texture(ch1, sampling_pos);
	vec4 wolf = texture(ch0, sampling_pos);
	
	vec4 eye_bloom = vec4(0.);
	for(int i = -6; i <= 6; i++)
	{
		for(int j = -6; j <= 6; j++)
		{
			vec2 dx = vec2(i,j);
			vec4 eye = texture(ch1, sampling_pos + dx/vec2(340,1600));
			eye_bloom += kernel(dx/4.)*vec4(removewhite(eye).xyz,1.);
		}
	}
	eye_bloom.xyz /= eye_bloom.w;
	O = 0.7*removewhite(wolf) + 8.*(0.7 + 0.3*sin(vec4(1,2,3,4)*(3.*iTime + 0.02*(P.x + 0.5*P.y))))*eye_bloom + removewhite(eyes);
}

out vec4 FragColor;
in vec2 uv;

void main()
{    
	mainImage(FragColor, uv*iResolution.xy);
	FragColor.w = 1.;
}