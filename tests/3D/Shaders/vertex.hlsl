struct VSInput
{
 float3 position : POSITION;
 float4 color : COLOR0;
};

struct PSInput
{
  float4 color : COLOR0;
};

PSInput main(VSInput input)
{
   PSInput output;
   
   output.color = float4(1, 1, 1, 1);
   
   return output;
}