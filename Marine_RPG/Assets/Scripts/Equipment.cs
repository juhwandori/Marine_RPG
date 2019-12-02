using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor.Animations;

public class Equipment : MonoBehaviour
{
    public enum EQUIP_TYPE { None, Melee, Pistol, Shotgun, Rifle, Sniper, Grenade };

    [Header("Equipment Settings")]
    public EQUIP_TYPE equipmentType;
    public string equipmentName;

    [Header("Animator Settings")]
    public AnimatorController animatorController;
}
