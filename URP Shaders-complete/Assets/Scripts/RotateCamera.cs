using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateCamera : MonoBehaviour
{
    public Transform target;
    private Transform control;

    // Start is called before the first frame update
    void Start()
    {
        if (target != null)
        {
            control = new GameObject().transform;

            control.position = target.position;
          
            transform.SetParent(control);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (target != null)
        {
            control.Rotate(Vector3.up, Time.deltaTime * 10f);
        }
    }
}
