using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThirdPersonCameraController : MonoBehaviour
{
    [Header("Camera Settings")]
    public float smoothTime = 0.5f;

    [SerializeField]
    private Vector3 offset;

    private Camera myCam;

    private void Awake()
    {
        myCam = GetComponent<Camera>();
        offset = transform.position - PlayerController.instance.transform.position;
    }

    private void LateUpdate()
    {
        UpdateCamPos();
    }

    private void UpdateCamPos()
    {
        Vector3 currentVelocity = Vector3.zero;
        transform.position = Vector3.SmoothDamp(transform.position, PlayerController.instance.transform.position + offset, ref currentVelocity, smoothTime);
    }
}
