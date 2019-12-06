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
    private float freeLookXAxisValue_temp;
    private float freeLookXAxisInitValue;
    private float aimCamXAxisInitValue;
    private float aimCamYAxisInitValue;
    private Transform aimPivot;

    #endregion

    #region MonoBehaviour Callbacks

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
        instance = this;
        anim = GetComponent<Animator>();
        rb = GetComponent<Rigidbody>();
        PE = GetComponent<PlayerEquipment>();
        aimPivot = transform.Find("Aim pivot");
    }

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        freeLookXAxisInitValue = freeLookCam.m_XAxis.Value;
        aimCamXAxisInitValue = aimCam.m_XAxis.Value;
        aimCamYAxisInitValue = aimCam.m_YAxis.Value;
        TurnOffAimCam();
    }

    private void Update()
    {
        /////////////////////////// Move ///////////////////////////////////////////
        float horizontalInput = Input.GetAxisRaw("Horizontal");
        float verticalInput = Input.GetAxisRaw("Vertical");
        Vector3 unitOffset = new Vector3(horizontalInput, 0, verticalInput).normalized;
        unitOffset = transform.TransformDirection(unitOffset);
        /*        int horizontalInput = 0;
                int verticalInput = 0;
                if (Input.GetKeyDown(GameManager.instance.forward)) verticalInput += 1;
                if (Input.GetKeyDown(GameManager.instance.backward)) verticalInput -= 1;
                if (Input.GetKeyUp(GameManager.instance.forward) || Input.GetKeyUp(GameManager.instance.backward)) verticalInput = 0;

                if (Input.GetKeyDown(GameManager.instance.right)) horizontalInput += 1;
                if (Input.GetKeyDown(GameManager.instance.left)) horizontalInput -= 1;
                if (Input.GetKeyUp(GameManager.instance.right) || Input.GetKeyUp(GameManager.instance.left)) horizontalInput = 0;

                Vector3 unitOffset = transform.right * horizontalInput + transform.forward * verticalInput;*/

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
                TurnOnAimCam();
/*                aimCamXAxisInitValue += mouseX;
                aimCamYAxisInitValue += mouseY;
                aimCam.m_XAxis.Value = aimCamXAxisInitValue;
                aimCam.m_YAxis.Value = aimCamYAxisInitValue;*/
                anim.SetBool("aim", true);
                PE.currentEquipedEquipment.UpdateRotation(new Vector3(-206.731f, -166.346f, 18.21899f));  // 슈퍼 하드 코딩 (제출 후 수정)
                if (Input.GetKeyDown(GameManager.instance.fire))
                {
                    PE.currentEquipedEquipment.On(Camera.main.ScreenPointToRay(Input.mousePosition));
                }
                else if (Input.GetKey(GameManager.instance.fire))
                {
                    PE.currentEquipedEquipment.UpdateTargetDirection(Camera.main.ScreenPointToRay(Input.mousePosition));
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

                TurnOffAimCam();
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
            freeLookCam.m_XAxis.Value = freeLookXAxisValue_temp;
        }
        else
        {
            freeLookXAxisInitValue += mouseX;
            freeLookCam.m_XAxis.Value = freeLookXAxisInitValue;
            aimCamXAxisInitValue += mouseX;
            //aimCamYAxisInitValue += mouseY;
            aimCam.m_XAxis.Value = aimCamXAxisInitValue;
            aimCam.m_YAxis.Value = aimCamYAxisInitValue;
            transform.Rotate(Vector3.up * mouseX, Space.Self);
        }
    }

    #endregion

    #region Public Functions

    public void Move(Vector3 offset)
    {
        transform.localPosition = Vector3.SmoothDamp(transform.localPosition, transform.localPosition + offset, ref currentVelocity, smoothTime);
        anim.SetFloat("movementSpeed", (currentVelocity.magnitude * 10));
    }

    #endregion

    #region Private Functions

    private void TurnOnAimCam()
    {
        freeLookCam.m_Priority = 0;
        aimCam.m_Priority = 1;
        aimCam.m_XAxis.Value = aimCamXAxisInitValue;
        aimCam.m_YAxis.Value = aimCamYAxisInitValue;
    }

    private void TurnOffAimCam()
    {
        freeLookCam.m_Priority = 1;
        freeLookCam.m_XAxis.Value = 0;
        aimCam.m_Priority = 0;
    }

    #endregion
}
