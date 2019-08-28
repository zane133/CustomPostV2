using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestWillRender : MonoBehaviour
{
    public Renderer rend;

    private float timePass = 0.0f;

    void Start()
    {
        //  当这个render为可见的时候才行
        rend = GetComponent<Renderer>();
    }

    void OnWillRenderObject()
    {
        timePass += Time.deltaTime;

        if (timePass > 1.0f)
        {
            timePass = 0.0f;
            print(gameObject.name + " is being rendered by " + Camera.current.name + " at " + Time.time);
        }
    }
}
