cbuffer CBuffer
{
  matrix world;
  matrix view;
  matrix proj;
};

struct VSInput
{
 float4 position : POSITION;
 float4 color : COLOR;
};

struct PSInput
{
  float4 position : SV_POSITION;
  float4 color : COLOR;
};

PSInput main(VSInput input)
{
   PSInput output;
   
   input.position.w = 1.0f;
   
   output.position = mul(world, input.position);
   output.position = mul(view, output.position);
   output.position = mul(proj, output.position);
   
   output.color = input.color;

   return output;
}