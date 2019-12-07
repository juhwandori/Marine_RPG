﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using NaughtyAttributes;

public class GameManager : MonoBehaviour
{
    #region Static Variables

    public static GameManager instance
    {
        set
        {
            if (_instance == null) _instance = value;
            else Destroy(value);
        }
        get { return _instance; }
    }
    public static GameManager _instance;

    #endregion

    #region Public Variables;

    [Header("Player Key Settings")]
    public KeyCode forward = KeyCode.W;
    public KeyCode right = KeyCode.D;
    public KeyCode left = KeyCode.A;
    public KeyCode backward = KeyCode.S;
    public KeyCode sprint = KeyCode.LeftShift;
    public KeyCode walk = KeyCode.LeftControl;
    public KeyCode fire = KeyCode.Mouse0;
    public KeyCode aim = KeyCode.Mouse1;
    public KeyCode reload = KeyCode.R;
    public float mouseSensitivity = 1f;

    [Header("Enemy Spawn Settings")]
    public List<EnemySpawner> enemySpawners = new List<EnemySpawner>();
    public float spawnDelay = 5f;
    public bool noise;

    #endregion

    public void StartGame()
    {
        SceneManager.LoadScene(1);
    }

    public void ExitGame()
    {

    }

    private void Awake()
    {
        //DontDestroyOnLoad(gameObject);
        instance = this;
    }

    private void Start()
    {
        if (enemySpawners != null)
        {
            OnEnemySpawners();
        }
    }

    private void OnEnemySpawners()
    {
        object[] data = { spawnDelay, noise };
        if (enemySpawners == null) return;
        foreach (EnemySpawner spawner in enemySpawners) spawner.StartCoroutine("Generate", data);
    }
}
