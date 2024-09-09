struct INPUT {
  float4 position : SV_POSITION;
  float4 normal : TEXCOORD0;
  float3 lightdir : TEXCOORD1;
  float4 color : COLOR;
};

float4 main(INPUT input) : SV_TARGET {
  float4 ambient = {0.0, 0.1, 0.3, 1.0};
  input.color.a = 1.0f;
  float ambient_contribution = 0.1f;
  float diffuse_contribution = 0.6f;
  float lighting_contribution = 1.0f - diffuse_contribution - ambient_contribution;

  return ambient_contribution * ambient + diffuse_contribution * input.color +
         lighting_contribution * input.color * saturate(dot(input.lightdir, input.normal));
}
