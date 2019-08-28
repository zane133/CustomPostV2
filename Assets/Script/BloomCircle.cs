using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class BloomCircle : MonoBehaviour
{
    [Range(0, 10)]
    public float Intensity = 2;
    public GameObject glowTargets = null;

    public static Material compositeMat;
    public static Material blurMat;

    private CommandBuffer commandBuffer = null;

    private static RenderTexture prePass;
    private static RenderTexture blurred;
    private static RenderTexture temp;

    void OnEnable()
    {
        prePass = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Default);
        blurred = new RenderTexture(Screen.width >> 2, Screen.height >> 2, 0);

        var glowSystem = CustomGlowSystem.Instance;
        blurMat = new Material(Shader.Find("Unlit/Gos"));
        blurMat.SetVector("_BlurSize", new Vector2(blurred.texelSize.x * 1.5f, blurred.texelSize.y * 1.5f));

        commandBuffer = new CommandBuffer();
        commandBuffer.SetRenderTarget(prePass);
        commandBuffer.ClearRenderTarget(true, true, Color.black);
        foreach (var obj in glowSystem.GlowObjs)
        {
            Renderer render = obj.GetComponent<Renderer>();
            commandBuffer.DrawRenderer(render, obj.glowMaterial);
        }

        temp = RenderTexture.GetTemporary(blurred.width, blurred.height);
        commandBuffer.Blit(prePass, blurred);

        for (int i = 0; i < 5; i++)
        {
            commandBuffer.Blit(blurred, temp, blurMat, 0);
            commandBuffer.Blit(temp, blurred, blurMat, 1);
        }

        compositeMat = new Material(Shader.Find("Unlit/GlowComposite"));
        compositeMat.SetTexture("_GlowPrePassTex", prePass);
        compositeMat.SetTexture("_GlowBlurredTex", blurred);
        

    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        compositeMat.SetTexture("_ScreenTex", src);
        //Graphics.ExecuteCommandBuffer(commandBuffer);
        compositeMat.SetFloat("_Intensity", Intensity);
        Graphics.Blit(src, dst, compositeMat, 0);
    }

    void OnDisable()
    {
        RenderTexture.ReleaseTemporary(temp);
    }
}
