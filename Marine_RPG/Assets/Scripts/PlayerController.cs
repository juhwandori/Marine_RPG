using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor.Animations;

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

    [Header("Animation Settings")]
    public float idleAnimationSwapPr;

    #endregion

    #region Private Variables

    private bool isRun = true;
    private bool isSprint = false;
    private Rigidbody rb;
    private Vector3 currentVelocity = Vector3.zero;
    private float pingpong;

    #endregion

    #region MonoBehaviour Callbacks

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
        instance = this;
        anim = GetComponent<Animator>();
        rb = GetComponent<Rigidbody>();
    }

    private void Update()
    {
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
