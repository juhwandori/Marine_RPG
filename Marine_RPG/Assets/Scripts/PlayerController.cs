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

    #endregion

    #region MonoBehaviour Callbacks

    private void Awake()
    {
        instance = this;
        anim = GetComponent<Animator>();
    }

    #endregion
}
