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
    public List<LayerMask> targetLayerMasks = new List<LayerMask>();
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
    private ParticleSystem hit;
    private int targetLayerMask;
    private Vector3 targetDirection;

    #endregion

    #region MonoBehaviour Callbacks

    private void OnEnable()
    {
        currentAmmo = ammo;
        muzzle = transform.Find("Muzzle");
        muzzleFlash = transform.Find("Muzzle_Flash").GetComponent<ParticleSystem>();
        hit = transform.Find("Hit").GetComponent<ParticleSystem>();
        foreach (LayerMask lm in targetLayerMasks)
        {
            targetLayerMask += (1 << lm);
        }
        targetLayerMask = ~targetLayerMask;
    }

    #endregion

    #region Public Functions

    public void On(Vector3 targetDirection)
    {
        UpdateTargetDirection(targetDirection);
        switch (equipmentType)
        {
            case EQUIP_TYPE.Melee:
                break;
            case EQUIP_TYPE.Pistol:
                break;
            case EQUIP_TYPE.Shotgun:
                break;
            case EQUIP_TYPE.AssaultRifle:
                if (auto) StartCoroutine("Auto");
                else SemiAuto();
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
        switch (equipmentType)
        {
            case EQUIP_TYPE.Melee:
                break;
            case EQUIP_TYPE.Pistol:
                break;
            case EQUIP_TYPE.Shotgun:
                break;
            case EQUIP_TYPE.AssaultRifle:
                if (auto) StopCoroutine("Auto");
                break;
            case EQUIP_TYPE.Sniper:
                break;
            case EQUIP_TYPE.Grenade:
                break;
            default:
                break;
        }
    }

    public void UpdateTargetDirection(Vector3 updateValue)
    {
        this.targetDirection = updateValue;
    }

    public void UpdateRotation(Vector3 targetRotation)
    {
        transform.localEulerAngles = targetRotation;
    }

    #endregion

    private IEnumerator Auto()
    {
        while (true)
        {
            SemiAuto();
            if (currentAmmo <= 0) yield break;
            yield return new WaitForSeconds(roundsPerMinute / (60 * 60));
        }
    }

    private void SemiAuto()
    {
        if (currentAmmo <= 0) return;

        Ray track = new Ray(muzzle.transform.position, targetDirection);

        Physics.Raycast(track, out RaycastHit hitInfo, effectiveRange, targetLayerMask, QueryTriggerInteraction.Ignore);
        Debug.DrawRay(track.origin, track.direction * effectiveRange, Color.green);
        muzzleFlash.Play();

        if (hitInfo.collider != null)
        {
            // Damage (Enemy Script 작성 후)
            ParticleSystem hitInstance = Instantiate(hit, hitInfo.point + hitInfo.normal * 0.1f, Quaternion.identity);
            hitInstance.Play();
            Destroy(hitInstance.gameObject, hitInstance.main.duration + hitInstance.main.startLifetimeMultiplier);
        }
        currentAmmo--;
    }

    #region Attribute Functions

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

    #endregion
}