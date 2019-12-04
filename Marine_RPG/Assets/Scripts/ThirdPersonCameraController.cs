using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NaughtyAttributes;

public class ThirdPersonCameraController : MonoBehaviour
{
    [Header("Look Settings")]
    public Vector3 lookOffset;

    [Header("Follow Settings")]
    public float smoothTime = 0.1f;

    [ShowNonSerializedField]
    private Vector3 positionOffset;
    [ShowNonSerializedField]
    private Vector3 rotationOffset;
    private Camera myCam;

    private void Awake()
    {
        myCam = GetComponent<Camera>();
    }

    private void Start()
    {
        positionOffset = transform.position - PlayerController.instance.transform.position;
        transform.LookAt(PlayerController.instance.transform);
        transform.localEulerAngles += lookOffset;
    }

    private void LateUpdate()
    {
        UpdateCamPos();
    }

    private void UpdateCamPos()
    {
        transform.position = Vector3.Lerp(transform.position, PlayerController.instance.transform.position + positionOffset, Time.deltaTime);
    }
}
