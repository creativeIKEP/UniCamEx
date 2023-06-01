Shader "UniCamEx/Flip"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            #define FLT_EPSILON 1.192092896e-07

            float3 PositivePow(float3 base, float3 power)
            {
                return pow(max(abs(base), float3(FLT_EPSILON, FLT_EPSILON, FLT_EPSILON)), power);
            }

            half3 SRGBToLinear(half3 c)
            {
                half3 linearRGBLo = c / 12.92;
                half3 linearRGBHi = PositivePow((c + 0.055) / 1.055, half3(2.4, 2.4, 2.4));
                half3 linearRGB = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
                return linearRGB;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                uv.y = 1.0f - uv.y;
                fixed4 col = tex2D(_MainTex, uv);

                #if UNITY_COLORSPACE_GAMMA
                col.rgb = SRGBToLinear(col.rgb);
                #endif

                return col;
            }
            ENDCG
        }
    }
}
