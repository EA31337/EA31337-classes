cbuffer MVP : register(b0) {
  matrix world;
  matrix view;
  matrix projection;
  float3 lightdir;
  float4 mat_color;
};

struct INPUT {
  float4 position : POSITION;
  float3 normal : NORMAL;
  float4 color : COLOR;
};

struct OUTPUT {
  float4 position : SV_POSITION;
  float3 normal : TEXCOORD0;
  float3 lightdir : TEXCOORD1;
  float4 color : COLOR;
};

OUTPUT main(INPUT input) {
  OUTPUT output;

  matrix mvp = mul(mul(view, world), projection);
  output.position = mul(input.position, mvp);

  output.normal = normalize(mul(input.normal, world));
  output.lightdir = lightdir;
  output.color = input.color * mat_color;

  return output;
}
