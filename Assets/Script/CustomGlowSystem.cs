using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CustomGlowSystem
{
    private static CustomGlowSystem m_Instance;

    public static CustomGlowSystem Instance
    {
        get
        {
            if (m_Instance == null)
            {
                m_Instance = new CustomGlowSystem();
            }
            return m_Instance;
        }
    }

    public HashSet<CustomGlowObj> GlowObjs = new HashSet<CustomGlowObj>();

    public void Add(CustomGlowObj obj)
    {
        Remove(obj);
        GlowObjs.Add(obj);
        Debug.Log("addedct " + obj.name);
    }

    public void Remove(CustomGlowObj obj)
    {
        GlowObjs.Remove(obj);
        Debug.Log("removedct " + obj.name);
    }
}