using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager instance
    {
        set
        {
            if (_instance == null) _instance = value;
            else Destroy(value);
        }
        get { return _instance; }
    }
    public static GameManager _instance;


    #region Public Variables;

    [Header("Player Key Settings")]
    public KeyCode forward = KeyCode.W;
    public KeyCode right = KeyCode.D;
    public KeyCode left = KeyCode.A;
    public KeyCode backward = KeyCode.S;
    public KeyCode sprint = KeyCode.LeftShift;
    public KeyCode walk = KeyCode.LeftControl;
    public KeyCode fire = KeyCode.Mouse0;
    public KeyCode aim = KeyCode.Mouse1;

    #endregion

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
        instance = this;
    }
}
