﻿Shader "Unlit/WhiteFill"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
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
                float4 pos : SV_POSITION;
                float linearDepth : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
            };

            sampler2D_float _CameraDepthTexture;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.linearDepth = -(UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w);
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 c = float4(0, 0, 0, 1);

                // decode depth texture info
                float2 uv = i.screenPos.xy / i.screenPos.w; // normalized screen-space pos
                float camDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
                camDepth = Linear01Depth(camDepth); // converts z buffer value to depth value from 0..1
                
                float diff = saturate(i.linearDepth - camDepth);
                if(diff < 0.001)
                    c = float4(1, 0, 0, 1);
                
                return c;
                // return float4(camDepth, camDepth, camDepth, 1); // test camera depth value
                // return float4(i.linearDepth, i.linearDepth, i.linearDepth, 1); // test our depth
                // return float4(diff, diff, diff, 1);
            }
            ENDCG
        }
    }
}
