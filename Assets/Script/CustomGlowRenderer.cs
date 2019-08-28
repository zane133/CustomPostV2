using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;


[ExecuteInEditMode]
public class CustomGlowRenderer : MonoBehaviour
{
    private CommandBuffer m_GlowBuffer;
    private Dictionary<Camera, CommandBuffer> m_Cameras = new Dictionary<Camera, CommandBuffer>();

    private void Cleanup()
    {
        foreach (var cam in m_Cameras)
        {
            if (cam.Key)
                cam.Key.RemoveCommandBuffer(CameraEvent.BeforeLighting, cam.Value);
        }
        m_Cameras.Clear();
    }

    public void OnDisable()
    {
        Cleanup();
    }

    public void OnEnable()
    {
        Debug.Log("OnEnable");
        Cleanup();
    }

    public void OnWillRenderObject()
    {
        var render = gameObject.activeInHierarchy && enabled;
        if (!render)
        {
            Cleanup();
            return;
        }

        var cam = Camera.current;
        if (!cam)
            return;

        if (m_Cameras.ContainsKey(cam))
            return;

        // create new command buffer
        m_GlowBuffer = new CommandBuffer();
        m_GlowBuffer.name = "Glow map buffer";
        m_Cameras[cam] = m_GlowBuffer;

        var glowSystem = CustomGlowSystem.Instance;

        // create render texture for glow map
        int tempID = Shader.PropertyToID("_Temp1");
        m_GlowBuffer.GetTemporaryRT(tempID, -1, -1, 24, FilterMode.Bilinear);
        m_GlowBuffer.SetRenderTarget(tempID);
        m_GlowBuffer.ClearRenderTarget(true, true, Color.black); // clear before drawing to it each frame!!

        // draw all glow objects to it
        foreach (CustomGlowObj o in glowSystem.GlowObjs)
        {
            Renderer r = o.GetComponent<Renderer>();
            Material glowMat = o.glowMaterial;
            if (r && glowMat)
                m_GlowBuffer.DrawRenderer(r, glowMat);
        }

        // set render texture as globally accessable 'glow map' texture
        m_GlowBuffer.SetGlobalTexture("_GlowMap", tempID);

        // add this command buffer to the pipeline
        cam.AddCommandBuffer(CameraEvent.BeforeLighting, m_GlowBuffer);
        Debug.Log("====== Rendering end");

    }
}