using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomRotator : MonoBehaviour
{
    public float rotateSpeed = 30f;
    public enum RotateDirection { X, Y, Z };
    public List<RotateDirection> rotateDirections = new List<RotateDirection>();

    private void Update()
    {
        for (int i = 0; i < rotateDirections.Count; i++)
        {
            switch (rotateDirections[i])
            {
                case RotateDirection.X:
                    transform.Rotate(Vector3.right, rotateSpeed * Time.deltaTime, Space.Self);
                    break;
                case RotateDirection.Y:
                    transform.Rotate(Vector3.up, rotateSpeed * Time.deltaTime, Space.Self);
                    break;
                case RotateDirection.Z:
                    transform.Rotate(Vector3.forward, rotateSpeed * Time.deltaTime, Space.Self);
                    break;
            }
        }
    }
}
