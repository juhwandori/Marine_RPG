using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerEquipment : MonoBehaviour
{
    #region Public Variables

    [Header("Equipments")]
    public List<Equipment> equipments = new List<Equipment>();
    public Equipment currentEquipedEquipment;

    [Space(10)]
    public Transform weaponPivot;
    public Text weaponText;
    public Color blue;
    public Color red;
    public Text ammoText;


    public Equipment testEquipment;
    public Equipment testEquipment1;

    #endregion

    #region MonoBehaviour Callbacks

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            Equip(testEquipment);
            weaponText.text = "Red";
            weaponText.color = red;
            ammoText.color = red;
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            Equip(testEquipment1);
            weaponText.text = "Blue";
            weaponText.color = blue;
            ammoText.color = blue;
        }
        if (currentEquipedEquipment != null)
        {
            ammoText.text = currentEquipedEquipment.currentAmmo.ToString() + "/" + currentEquipedEquipment.ammo.ToString(); 
        }
    }

    #endregion

    #region Public Functions

    public void Equip(Equipment equipment)
    {
        UnEquip();
        Equipment instance;

        foreach (Equipment equip in equipments)
        {
            if (equip == equipment)
            {
                instance = Instantiate(equip, weaponPivot, false);
                currentEquipedEquipment = instance;
                return;
            }
        }

        equipments.Add((Resources.Load(equipment.name) as GameObject).GetComponent<Equipment>());
        instance = Instantiate(equipments[equipments.Count - 1], weaponPivot, false);
        currentEquipedEquipment = instance;
        PlayerController.instance.anim.runtimeAnimatorController = currentEquipedEquipment.animatorController;
    }

    public void UnEquip()
    {
        if (weaponPivot.childCount != 0)
        {
            // UnEquip 애니메이션 재생
            // Destroy(weaponPivot.GetChild(0), animation.time);
            Destroy(weaponPivot.GetChild(0).gameObject);
            currentEquipedEquipment = null;
        }
    }

    #endregion
}
