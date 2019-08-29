using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public float Speed = 10;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        var deltaTime = Time.deltaTime * Speed;
        transform.rotation *= Quaternion.Euler(deltaTime, deltaTime, deltaTime);
    }
}
