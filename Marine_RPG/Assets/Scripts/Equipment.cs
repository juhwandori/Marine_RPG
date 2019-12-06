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
    public List<LayerMask> targetValidator = new List<LayerMask>();
    [ShowIf("isGun")]
    public bool auto;
    [ShowIf(ConditionOperator.And, "isGun", "auto")]
    public float roundsPerMinute;
    [HideIf("auto")]
    public bool boltAction;
    [ShowIf("isGun")]
    public int damagePerBullet;
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

    [HideInInspector]
    public int currentAmmo;
    #endregion

    #region Private Variables

    private Transform muzzle;
    private ParticleSystem muzzleFlash;
    private ParticleSystem hit;
    private int targetLayerMask;
    private Ray bulletTrack;
    private Light muzzleFlashLight;

    #endregion

    #region MonoBehaviour Callbacks

    private void OnEnable()
    {
        currentAmmo = ammo;
        muzzle = transform.Find("Muzzle");
        muzzleFlashLight = muzzle.GetComponent<Light>();
        muzzleFlashLight.enabled = false;
        muzzleFlash = transform.Find("Muzzle_Flash").GetComponent<ParticleSystem>();
        hit = transform.Find("Hit").GetComponent<ParticleSystem>();
        foreach (LayerMask lm in targetValidator)
        {
            targetLayerMask += (1 << lm);
        }
        targetLayerMask = ~targetLayerMask;
    }

    #endregion

    #region Public Functions

    public void On(Ray updateValue)
    {
        UpdateTargetDirection(updateValue);
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

    public void UpdateTargetDirection(Ray updateValue)
    {
        this.bulletTrack = updateValue;
    }

    public void UpdateRotation(Vector3 targetRotation)
    {
        transform.localEulerAngles = targetRotation;
    }

    public IEnumerator Reloading(float delay)
    {
        yield return new WaitForSeconds(delay);
        currentAmmo = ammo;
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
        Physics.Raycast(bulletTrack, out RaycastHit hitInfo, effectiveRange, targetLayerMask, QueryTriggerInteraction.Ignore);
        Debug.DrawRay(bulletTrack.origin, bulletTrack.direction * effectiveRange, Color.green, 0.3f);
        muzzleFlash.Play();
        StartCoroutine(OnMuzzleLight());

        if (hitInfo.collider != null)
        {
            if (hitInfo.collider.CompareTag("Enemy"))
            {
                print('a');
                Enemy target = hitInfo.collider.GetComponentInParent<Enemy>();
                target.TakeDamage(damagePerBullet);
            }
            ParticleSystem hitInstance = Instantiate(hit, hitInfo.point + hitInfo.normal * 0.1f, Quaternion.identity);
            hitInstance.Play();
            Destroy(hitInstance.gameObject, hitInstance.main.duration + hitInstance.main.startLifetimeMultiplier);
        }
        currentAmmo--;
    }

    private IEnumerator OnMuzzleLight() 
    {
        muzzleFlashLight.enabled = true;
        yield return new WaitForSeconds(0.14f);
        muzzleFlashLight.enabled = false;
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