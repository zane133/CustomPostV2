Shader "Unlit/GlowComposite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _ScreenTex;
            float4 _ScreenTex_ST;
            sampler2D _GlowPrePassTex;
            float4 _GlowPrePassTex_ST;
            sampler2D _GlowBlurredTex;
            float4 _GlowBlurred_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_ScreenTex, i.uv);
                fixed4 col1 = tex2D(_GlowPrePassTex, i.uv);
                fixed4 col2 = tex2D(_GlowBlurredTex, i.uv);

                return col + col1 + col2;
            }
            ENDCG
        }
    }
}
