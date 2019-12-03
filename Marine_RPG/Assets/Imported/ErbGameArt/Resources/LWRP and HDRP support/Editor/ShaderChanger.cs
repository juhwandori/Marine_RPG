using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class RPChanger : EditorWindow
{

    [MenuItem("Window/EGA-VFX Pipeline changer")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow(typeof(RPChanger));
    }

    public void OnGUI()
    {
        GUILayout.Label("Change pipeline to:");

        if (GUILayout.Button("Standard RP"))
        {
            FindShaders();
            ChangeToSRP();
        }
        if (GUILayout.Button("Lightweight RP"))
        {
            FindShaders();
            ChangeToLWRP();
        }
        if (GUILayout.Button("HD RP (From Unity 2018.3+)"))
        {
            FindShaders();
            ChangeToHDRP();
        }
    }

    Shader LightGlow;
    Shader Lit_CenterGlow;
    Shader Blend_TwoSides;
    Shader Blend_Normals;
    Shader Ice;

    Shader LightGlow_LWRP;
    Shader Lit_CenterGlow_LWRP;
    Shader Blend_TwoSides_LWRP;
    Shader Blend_Normals_LWRP;
    Shader Ice_LWRP;

    Shader LightGlow_HDRP;
    Shader Lit_CenterGlow_HDRP;
    Shader Blend_TwoSides_HDRP;
    Shader Blend_Normals_HDRP;
    Shader Ice_HDRP;

    Material[] shaderMaterials;

    private void FindShaders()
    {
        if (Shader.Find("ERB/Particles/LightGlow") != null) LightGlow = Shader.Find("ERB/Particles/LightGlow");
        if (Shader.Find("ERB/Particles/Lit_CenterGlow") != null) Lit_CenterGlow = Shader.Find("ERB/Particles/Lit_CenterGlow");
        if (Shader.Find("ERB/Particles/Blend_TwoSides") != null) Blend_TwoSides = Shader.Find("ERB/Particles/Blend_TwoSides");
        if (Shader.Find("ERB/Particles/Blend_Normals") != null) Blend_Normals = Shader.Find("ERB/Particles/Blend_Normals");
        if (Shader.Find("ERB/Particles/Ice") != null) Ice = Shader.Find("ERB/Particles/Ice");

        if (Shader.Find("ERB/LWRP/Particles/LightGlow") != null) LightGlow_LWRP = Shader.Find("ERB/LWRP/Particles/LightGlow");
        if (Shader.Find("ERB/LWRP/Particles/Lit_CenterGlow") != null) Lit_CenterGlow_LWRP = Shader.Find("ERB/LWRP/Particles/Lit_CenterGlow");
        if (Shader.Find("ERB/LWRP/Particles/Blend_TwoSides") != null) Blend_TwoSides_LWRP = Shader.Find("ERB/LWRP/Particles/Blend_TwoSides");
        if (Shader.Find("ERB/LWRP/Particles/Blend_Normals") != null) Blend_Normals_LWRP = Shader.Find("ERB/LWRP/Particles/Blend_Normals");
        if (Shader.Find("ERB/LWRP/Particles/Ice") != null) Ice_LWRP = Shader.Find("ERB/LWRP/Particles/Ice");

        if (Shader.Find("ERB/HDRP/Particles/LightGlow") != null) LightGlow_HDRP = Shader.Find("ERB/HDRP/Particles/LightGlow");
        if (Shader.Find("Shader Graphs/HDRP_Lit_CenterGlow") != null) Lit_CenterGlow_HDRP = Shader.Find("Shader Graphs/HDRP_Lit_CenterGlow");
        if (Shader.Find("ERB/HDRP/Particles/Blend_TwoSides") != null) Blend_TwoSides_HDRP = Shader.Find("ERB/HDRP/Particles/Blend_TwoSides");
        if (Shader.Find("ERB/HDRP/Particles/Blend_Normals") != null) Blend_Normals_HDRP = Shader.Find("ERB/HDRP/Particles/Blend_Normals");
        if (Shader.Find("ERB/HDRP/Particles/Ice") != null) Ice_HDRP = Shader.Find("ERB/HDRP/Particles/Ice");

        string[] folderMat = AssetDatabase.FindAssets("t:Material", new[] { "Assets/ErbGameArt" });
        shaderMaterials = new Material[folderMat.Length];

        for (int i = 0; i < folderMat.Length; i++)
        {
            var patch = AssetDatabase.GUIDToAssetPath(folderMat[i]);
            shaderMaterials[i] = (Material)AssetDatabase.LoadAssetAtPath(patch, typeof(Material));
        }
    }

    private void ChangeToLWRP()
    {

        foreach (var material in shaderMaterials)
        {
            if (Shader.Find("ERB/LWRP/Particles/LightGlow") != null)
            {
                if (material.shader == LightGlow || material.shader == LightGlow_HDRP)
                {
                    material.shader = LightGlow_LWRP;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/LWRP/Particles/Lit_CenterGlow") != null)
            {
                if (material.shader == Lit_CenterGlow || material.shader == Lit_CenterGlow_HDRP)
                {
                    material.shader = Lit_CenterGlow_LWRP;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/LWRP/Particles/Blend_TwoSides") != null)
            {
                if (material.shader == Blend_TwoSides || material.shader == Blend_TwoSides_HDRP)
                {
                    material.shader = Blend_TwoSides_LWRP;
                }
            }     
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/LWRP/Particles/Blend_Normals") != null)
            {
                if (material.shader == Blend_Normals || material.shader == Blend_Normals_HDRP)
                {
                    material.shader = Blend_Normals_LWRP;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/LWRP/Particles/Ice") != null)
            {
                if (material.shader == Ice || material.shader == Ice_HDRP)
                {
                    material.shader = Ice_LWRP;
                }
            }
        }
    }


    private void ChangeToSRP()
    {

        foreach (var material in shaderMaterials)
        {
            if (Shader.Find("ERB/Particles/LightGlow") != null)
            {
                if (material.shader == LightGlow_LWRP || material.shader == LightGlow_HDRP)
                {
                    material.shader = LightGlow;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/Particles/Lit_CenterGlow") != null)
            {
                if (material.shader == Lit_CenterGlow_LWRP || material.shader == Lit_CenterGlow_HDRP)
                {
                    material.shader = Lit_CenterGlow;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/Particles/Blend_TwoSides") != null)
            {
                if (material.shader == Blend_TwoSides_LWRP || material.shader == Blend_TwoSides_HDRP)
                {
                    material.shader = Blend_TwoSides;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/Particles/Blend_Normals") != null)
            {
                if (material.shader == Blend_Normals_LWRP || material.shader == Blend_Normals_HDRP)
                {
                    material.shader = Blend_Normals;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/Particles/Ice") != null)
            {
                if (material.shader == Ice_LWRP || material.shader == Ice_HDRP)
                {
                    material.shader = Ice;
                }
            }
        }
    }

    private void ChangeToHDRP()
    {
        foreach (var material in shaderMaterials)
        {
            if (Shader.Find("ERB/HDRP/Particles/LightGlow") != null)
            {
                if (material.shader == LightGlow || material.shader == LightGlow_LWRP)
                {
                    material.shader = LightGlow_HDRP;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("Shader Graphs/HDRP_Lit_CenterGlow") != null)
            {
                if (material.shader == Lit_CenterGlow || material.shader == Lit_CenterGlow_LWRP)
                {
                    material.shader = Lit_CenterGlow_HDRP;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/HDRP/Particles/Blend_TwoSides") != null)
            {
                if (material.shader == Blend_TwoSides || material.shader == Blend_TwoSides_LWRP)
                {
                    material.shader = Blend_TwoSides_HDRP;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/HDRP/Particles/Blend_Normals") != null)
            {
                if (material.shader == Blend_Normals || material.shader == Blend_Normals_LWRP)
                {
                    material.shader = Blend_Normals_HDRP;
                }
            }
            /*----------------------------------------------------------------------------------------------------*/
            if (Shader.Find("ERB/HDRP/Particles/Ice") != null)
            {
                if (material.shader == Ice || material.shader == Ice_LWRP)
                {
                    material.shader = Ice_HDRP;
                }
            }
        }
    }
}