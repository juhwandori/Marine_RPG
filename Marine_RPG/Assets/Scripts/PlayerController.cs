using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor.Animations;
using Cinemachine;

public class PlayerController : MonoBehaviour
{
    #region Static Variables

    public static PlayerController instance
    {
        set
        {
            if (_instance == null) _instance = value;
            else Destroy(value);
        }
        get { return _instance; }
    }
    private static PlayerController _instance = null;

    #endregion

    #region Public Variables

    [HideInInspector]
    public Animator anim;

    [Header("Movement Settings")]
    public float walkSpeed = 5f;
    public float runSpeed = 20f;
    public float sprintSpeed = 35f;
    public float smoothTime = 0.1f;

    [Header("Camera Settings")]
    public CinemachineFreeLook freeLookCam;
    public CinemachineFreeLook aimCam;

    #endregion

    #region Private Variables

    private bool isRun = true;
    private bool isSprint = false;
    private Rigidbody rb;
    private Vector3 currentVelocity = Vector3.zero;
    private PlayerEquipment PE;
    private bool aimed;
    private float freeLookXAxisValue_temp;

    #endregion

    #region MonoBehaviour Callbacks

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
        instance = this;
        anim = GetComponent<Animator>();
        rb = GetComponent<Rigidbody>();
        PE = GetComponent<PlayerEquipment>();
    }

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        freeLookCam.enabled = true;
        aimCam.enabled = false;
        freeLookCam.m_XAxis.Value = 0f;
        aimCam.m_XAxis.Value = 0f;
    }

    private void Update()
    {
        /////////////////////////// Move ///////////////////////////////////////////
        
        float horizontalInput = Input.GetAxisRaw("Horizontal");
        float verticalInput = Input.GetAxisRaw("Vertical");
        Vector3 unitOffset = new Vector3(horizontalInput, 0, verticalInput).normalized;

        if (Input.GetKeyDown(GameManager.instance.walk))
        {
            isRun = false;
            isSprint = false;
        }
        else if (Input.GetKeyDown(GameManager.instance.sprint))
        {
            isRun = false;
            isSprint = true;
        }

        if (Input.GetKeyUp(GameManager.instance.walk) || Input.GetKeyUp(GameManager.instance.sprint))
        {
            isRun = true;
            isSprint = false;
        }

        if (isSprint) Move(unitOffset * sprintSpeed * Time.deltaTime);
        else if (isRun) Move(unitOffset * runSpeed * Time.deltaTime);
        else Move(unitOffset * walkSpeed * Time.deltaTime);

        anim.SetInteger("horizontalMovementDirection", (int)horizontalInput);
        anim.SetInteger("verticalMovementDirection", (int)verticalInput);

        /////////////////////////// Aim ////////////////////////////////////////////

        if (PE.currentEquipedEquipment != null)
        {
            if (Input.GetKey(GameManager.instance.aim))
            {
                freeLookCam.enabled = false;
                aimCam.enabled = true;
                anim.SetBool("aim", true);
                PE.currentEquipedEquipment.UpdateRotation(new Vector3(-206.731f, -166.346f, 18.21899f));  // 슈퍼 하드 코딩 (제출 후 수정)
                if (Input.GetKeyDown(GameManager.instance.fire))
                {
                    PE.currentEquipedEquipment.On(transform.TransformDirection(transform.forward));
                }
                else if (Input.GetKey(GameManager.instance.fire))
                {
                    PE.currentEquipedEquipment.UpdateTargetDirection(transform.TransformDirection(transform.forward));
                    anim.SetBool("fire", true);
                }
                else if (Input.GetKeyUp(GameManager.instance.fire))
                {
                    PE.currentEquipedEquipment.Off();
                    anim.SetBool("fire", false);
                }
            }
            else if (Input.GetKeyUp(GameManager.instance.aim))
            {
                PE.currentEquipedEquipment.UpdateRotation(new Vector3(-195.121f, -97.14301f, 108.802f));  // 슈퍼 하드 코딩 (제출 후 수정)
                anim.SetBool("fire", false);
                anim.SetBool("aim", false);

                freeLookCam.enabled = true;
                aimCam.enabled = false;
            }
        }

        /////////////////////////// Rotate /////////////////////////////////////////
        float mouseX = Input.GetAxis("Mouse X") * GameManager.instance.mouseSensitivity * Time.deltaTime;

        if (Input.GetKeyDown(KeyCode.LeftAlt))
        {
            freeLookXAxisValue_temp = freeLookCam.m_XAxis.Value;
        }
        else if (Input.GetKey(KeyCode.LeftAlt))
        {
            freeLookCam.m_XAxis.m_InputAxisName = "Mouse X";
        }
        else if (Input.GetKeyUp(KeyCode.LeftAlt))
        {
            freeLookCam.m_XAxis.m_InputAxisName = null;
            freeLookCam.m_XAxis.Value = freeLookXAxisValue_temp;
        }
        else
        {
            freeLookCam.m_XAxis.Value += mouseX;
            aimCam.m_XAxis.Value += mouseX;
            transform.Rotate(Vector3.up * mouseX);
        }
    }

    #endregion

    #region Public Variables

    public void Move(Vector3 offset)
    {
        transform.position = Vector3.SmoothDamp(transform.position, transform.position + offset, ref currentVelocity, smoothTime);
        anim.SetFloat("movementSpeed", (currentVelocity.magnitude * 10));
    }

    #endregion
}
