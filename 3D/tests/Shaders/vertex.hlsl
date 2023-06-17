cbuffer MVP : register(b0)
{
  matrix world;
  matrix view;
  matrix projection;
  float3 lightdir;
};

struct INPUT
{
 float4 position : POSITION;
 float3 normal : NORMAL;
 float4 color : COLOR;
};

struct OUTPUT
{
  float4 position : SV_POSITION;
  float3 normal : TEXCOORD0;
  float3 lightdir : TEXCOORD1;
  float4 color : COLOR;
};

OUTPUT main(INPUT input)
{
   OUTPUT output;

   input.position.w = 1.0f;

   matrix mvp = mul(mul(projection, view), world);

   output.position = mul(mvp, input.position);

   output.normal = normalize(mul(world, input.normal));
   output.lightdir = lightdir;
   output.color = input.color;

   return output;
}
