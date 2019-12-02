using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
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

    private Animator anim;

    private void Awake()
    {
        instance = this;
        anim = GetComponent<Animator>();
    }
}
