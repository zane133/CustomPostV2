using UnityEngine;


[ExecuteInEditMode]
public class CustomGlowObj : MonoBehaviour
{
    public Material glowMaterial;

    public void OnEnable()
    {
        CustomGlowSystem.Instance.Add(this);
    }

    public void Start()
    {
        CustomGlowSystem.Instance.Add(this);
    }

    public void OnDisable()
    {
        CustomGlowSystem.Instance.Remove(this);
    }
}