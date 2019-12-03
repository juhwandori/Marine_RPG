using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerEquipment : MonoBehaviour
{
    #region Public Variables

    [Header("Equipments")]
    public List<Equipment> equipments = new List<Equipment>();
    public Equipment currentEquipedEquipment;

    [Space(10)]
    public Transform weaponPivot;



    public Equipment testEquipment;
    public Equipment testEquipment1;

    #endregion

    #region MonoBehaviour Callbacks

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            Equip(testEquipment);
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            Equip(testEquipment1);
        }
    }

    #endregion

    #region Public Functions

    public void Equip(Equipment equipment)
    {
        UnEquip();

        foreach (Equipment equip in equipments)
        {
            if (equip == equipment)
            {
                Instantiate(equip, weaponPivot, false);
                currentEquipedEquipment = equip;
                return;
            }
        }

        equipments.Add((Resources.Load(equipment.name) as GameObject).GetComponent<Equipment>());
        Instantiate(equipments[equipments.Count - 1], weaponPivot, false);
        currentEquipedEquipment = equipments[equipments.Count - 1];
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
