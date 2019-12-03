using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor.Animations;
using NaughtyAttributes;

public class Equipment : MonoBehaviour
{
    public enum EQUIP_TYPE { None, Melee, Pistol, Shotgun, AssaultRifle, Sniper, Grenade };

    #region Public Variables

    [Header("Equipment Settings")]
    public EQUIP_TYPE equipmentType;
    public string equipmentName;
    [ShowIf("isGun")]
    public bool auto;
    [ShowIf(ConditionOperator.And, "isGun", "auto")]
    public float roundsPerMinute;
    [HideIf("auto")]
    public bool boltAction;
    [ShowIf("isGun")]
    public float damagePerBullet;
    [ShowIf("isGun")]
    public float effectiveRange = 100f;
    [ShowIf("isGun")]
    public int ammo;
    [ShowIf("isGrenade")]
    public float explosionRadius;
    [ShowIf("isGrenade")]
    public float explosionDemage;
    [ShowIf("isGrenade")]
    public float explosionDelay;

    [Header("Animator Controller Settings")]
    public AnimatorController animatorController;

    #endregion

    #region Private Variables

    private int currentAmmo;
    private Transform muzzle;
    private ParticleSystem muzzleFlash;

    #endregion

    #region MonoBehaviour Callbacks

    private void OnEnable()
    {
        currentAmmo = ammo;
        muzzle = transform.Find("Muzzle");
        muzzleFlash = transform.Find("Muzzle_Flash").GetComponent<ParticleSystem>();
    }

    #endregion

    #region Public Functions

    public void On(Vector3 targetDirection = default)
    {
        switch (equipmentType)
        {
            case EQUIP_TYPE.Melee:
                break;
            case EQUIP_TYPE.Pistol:
                break;
            case EQUIP_TYPE.Shotgun:
                break;
            case EQUIP_TYPE.AssaultRifle:
                if (auto) StartCoroutine("Auto", targetDirection);
                else SemiAuto(targetDirection);
                break;
            case EQUIP_TYPE.Sniper:
                break;
            case EQUIP_TYPE.Grenade:
                break;
            default:
                break;
        }
    }

    public void Off()
    {

    }

    #endregion

    private IEnumerator Auto(Vector3 targetDirection)
    {
        while (true)
        {
            //Ray track = new Ray(muzzle.transform.position, )
        }
    }

    private void SemiAuto(Vector3 targetDirection)
    {

    }

    private bool isGun()
    {
        if (equipmentType != EQUIP_TYPE.None && equipmentType != EQUIP_TYPE.Grenade) return true;
        return false;
    }
    private bool isGrenade()
    {
        if (equipmentType == EQUIP_TYPE.Grenade) return true;
        return false;
    }
}