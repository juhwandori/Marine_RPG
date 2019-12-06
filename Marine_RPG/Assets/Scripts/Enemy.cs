using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    [Header("Attack Settings")]
    public float attackStatDelay = 0.4f;
    public float attackDuration = 0.5f;
    public float attackEndDelay = 0.1f;
    public GameObject attackEff;

    [Header("Movement Settings")]
    public float movementSpeed = 10f;
    public float smoothTime = 0.3f;
    
    [Space(10)]
    public int maxHP;
    public int currentHP;

    [Space(10)]
    public float deathDissolveSpeed = 0.3f;

    [HideInInspector]
    public Vector3 moveDirection;
    [HideInInspector]
    public Transform destination;

    private Animator anim;
    private Material mat;
    private Rigidbody rb;

    private void Awake()
    {
        anim = GetComponent<Animator>();
        rb = GetComponent<Rigidbody>();
        mat = transform.Find("PA_Warrior").GetComponent<SkinnedMeshRenderer>().material;
    }

    private void Start()
    {
        attackEff.SetActive(false);
        currentHP = maxHP;
    }

    public IEnumerator Move()
    {
        Vector3 currentVelocity = Vector3.zero;
        transform.LookAt(moveDirection);
        while (true)
        {
            transform.position = Vector3.SmoothDamp(transform.position, transform.position + (moveDirection * movementSpeed * Time.deltaTime), ref currentVelocity, smoothTime);
            yield return null;
        }
    }

    public void TakeDamage(int damage)
    {
        currentHP -= damage;

        if (currentHP <= 0)
        {
            StartCoroutine("Die");
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            anim.SetBool("Attack", true);
            StopCoroutine("Move");
            StartCoroutine("Attack");
            attackEff.transform.LookAt(PlayerController.instance.GetCenter());
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            attackEff.transform.LookAt(PlayerController.instance.GetCenter());
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            anim.SetBool("Attack", false);
            StopCoroutine("Attack");
            StartCoroutine("Move");
            attackEff.SetActive(false);
        }
    }
    
    private IEnumerator Attack()
    {
        while (true)
        {
            yield return new WaitForSeconds(anim.GetCurrentAnimatorClipInfo(0)[0].clip.length * attackStatDelay);
            attackEff.SetActive(true);
            yield return new WaitForSeconds(anim.GetCurrentAnimatorClipInfo(0)[0].clip.length * attackDuration);
            attackEff.SetActive(false);
            yield return new WaitForSeconds(anim.GetCurrentAnimatorClipInfo(0)[0].clip.length * attackEndDelay);
        }
    }

    private IEnumerator Die()
    {
        anim.SetTrigger("Die");
        float temp = 0;
        attackEff.SetActive(false);
        StopCoroutine("Move");
        StopCoroutine("Attack");
        transform.Find("PA_Warrior").GetComponent<Collider>().enabled = false;
        rb.isKinematic = true;

        mat.SetFloat("_DissolveMask", 0);
        mat.DisableKeyword("_DISSOLVEMASK_PLANE");

        while (true)
        {
            temp += Time.deltaTime * deathDissolveSpeed;
            mat.SetFloat("_DissolveCutoff", Mathf.Clamp01(temp));

            if (mat.GetFloat("_DissolveCutoff") == 1)
            {
                Destroy(this.gameObject);
                yield break;
            }
            yield return null;
        }
    }
}
