Shader "Unlit/GlowCompositeNoise"
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

            float _Intensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float noiseSampler(float3 xyz, float res)
			{
				xyz *= res;
				float3 xyz0 = floor(fmod(xyz,res)) * float3(1,200,1000);
				float3 xyz1 = floor(fmod(xyz + float3(1,1,1),res))  * float3(1,200,1000);

				float3 f = frac(xyz); f = f*f*(3.0-2.0*f);
				float4 v = float4(xyz0.x + xyz0.y + xyz0.z , xyz1.x  + xyz0.y + xyz0.z,
								xyz0.x   + xyz1.y + xyz0.z, xyz1.x  + xyz1.y + xyz0.z);
				float4 rand = frac(sin(v/res*6.2832)*1000.0);
				float r0 = lerp(lerp(rand.x,rand.y,f.x),lerp(rand.z,rand.w,f.x),f.y);

				rand = frac(sin((v - xyz0.z + xyz1.z)/res*6.2832)*1000.0);
				float r1 = lerp(lerp(rand.x,rand.y,f.x),lerp(rand.z,rand.w,f.x),f.y);
				return lerp(r0,r1,f.z);



			}


            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_ScreenTex, i.uv);
                fixed4 col1 = tex2D(_GlowPrePassTex, i.uv);
                fixed4 col2 = tex2D(_GlowBlurredTex, i.uv);


                // // return col2 - col1;
                // // return col + col1 + col2;
                // // fixed4 glow = col2 - col1;
                fixed4 glow = fixed4(lerp(col2,fixed3(0,0,0),col1.r), 1);
                return col + glow;


                // float2 _ObjPoint = float2(0.5,0.5);
                // float2 uvP = i.uv; 
                // uvP.x = uvP.x * _ScreenParams.x / _ScreenParams.y;

				// float x = atan2(uvP.y - _ObjPoint.y, uvP.x - _ObjPoint.x)/6.2832 + 0.5;
				// float y = length(float2(uvP.y - _ObjPoint.y, uvP.x - _ObjPoint.x));

                // float n = noiseSampler(float3(x,y*0.75 - _Time.x * 2, _Time.x * 0.15),16) * 1;
                // return col +  glow * _Intensity * n;
            }
            ENDCG
        }
    }
}
