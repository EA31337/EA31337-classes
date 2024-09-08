struct INPUT {
  float4 position : SV_POSITION;
  float4 normal : TEXCOORD0;
  float3 lightdir : TEXCOORD1;
  float4 color : COLOR;
};

float4 main(INPUT input) : SV_TARGET {
  float4 ambient = {0.0, 0.2, 0.4, 1.0};
  return ambient + input.color * saturate(dot(input.lightdir, input.normal));
}
//+------------------------------------------------------------------+
