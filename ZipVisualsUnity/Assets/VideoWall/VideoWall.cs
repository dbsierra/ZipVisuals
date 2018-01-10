using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VideoWall : MonoBehaviour {

    #region Parameters
    [Header("Video")]
    public Vector2 Resolution;

    [Header("Shader Parameters")]
    public Vector2 RowsCols;
    public float Phase;
    public float Mode;
    public float Mask;
    public float MaskFlip;
    public float GlitchColor;
    public float SpectrumMag;
    public float RGBShift;
    public float VHS;

    [Header("Color Themes")]
    public int CurrentTheme;
    public ColorTheme[] ColorThemes;
    #endregion

    #region Resources
    [Header("Resources")]
    public MeshRenderer Wall;
    public Material TextureWriteMat;
    public AudioSource Audio;

    private RenderTexture RenderTex;
    private float[] spectrum;
    #endregion

    bool ready;

    void Start () {
        spectrum = new float[256];

        RenderTex = new RenderTexture((int)Resolution.x, (int)Resolution.y, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
        RenderTex.filterMode = FilterMode.Point;

        // Initialize Variables
        TextureWriteMat.SetFloat("_Mask", 1);
        TextureWriteMat.SetFloat("_Static", 0);
        TextureWriteMat.SetFloat("_Mode", 3);
        TextureWriteMat.SetFloat("_SpectrumMag", .9f);
        TextureWriteMat.SetFloat("_MaskFlip", 1);
        TextureWriteMat.SetColor("_Col1", ColorThemes[CurrentTheme].c1);
        TextureWriteMat.SetColor("_Col2", ColorThemes[CurrentTheme].c2);
        TextureWriteMat.SetColor("_Col3", ColorThemes[CurrentTheme].c3);

        CurrentTheme = 0;

        ready = true;
    }
    
    void Update () {
        if (ready)
        {
            Audio.GetSpectrumData(spectrum, 0, FFTWindow.BlackmanHarris);

            TextureWriteMat.SetFloatArray("_Spectrum", spectrum);

            Graphics.Blit(null, RenderTex, TextureWriteMat);

            Wall.material.SetTexture("_MainTex", RenderTex);
        }
    }
}

[Serializable]
public class ColorTheme
{
    public Color c1;
    public Color c2;
    public Color c3;
    public Color accent;

    public ColorTheme()
    {

    }
}