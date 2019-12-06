using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawner : MonoBehaviour
{
    public Enemy enemyPrefab;
    public Transform destination;

    public IEnumerator Generate(object[] data)
    {
        float spawnDelay = (float)data[0];
        bool noise = (bool)data[1];
        while (true)
        {
            if (noise) yield return new WaitForSeconds(spawnDelay * Random.value); 
            Enemy instance = Instantiate(enemyPrefab, transform.position, Quaternion.identity);
            instance.moveDirection = destination.position - transform.position;
            instance.StartCoroutine("Move");
            yield return new WaitForSeconds(spawnDelay);
        }
    }
}

