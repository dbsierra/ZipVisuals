using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VideoWall : MonoBehaviour {

    #region Parameters
    [Header("Video")]
    public Vector2 Resolution;

    [Header("Shader Parameters")]
    public float Aspect;
    public Vector2 RowsCols;
    public float Phase;
    public float Mode;
    public float Mask;
    public float MaskFlip;
    public float GlitchColor;
    public float SpectrumMag;
    public float RGBShift;
    public float VHS;
    public float SquareMag;
    public float SquareRotate;
    #endregion

    #region Resources
    [Header("Resources")]
    public MeshRenderer Wall;
    public MeshRenderer Wall2;
    public Utilities.ColorThemes Themes;
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

        UpdateParams();

        ready = true;
    }
    
    void UpdateParams()
    {

        TextureWriteMat.SetFloat("_Rows", RowsCols.x);
        TextureWriteMat.SetFloat("_Cols", RowsCols.y);

        TextureWriteMat.SetFloat("_Square", SquareMag);
        TextureWriteMat.SetFloat("_Aspect", Aspect);
        TextureWriteMat.SetFloat("_Rotate", SquareRotate);



        TextureWriteMat.SetFloat("_Mask", Mask);
        TextureWriteMat.SetFloat("_Static", 0);
        TextureWriteMat.SetFloat("_Mode", Mode);
        TextureWriteMat.SetFloat("_SpectrumMag", SpectrumMag);
        TextureWriteMat.SetFloat("_MaskFlip", MaskFlip);
        TextureWriteMat.SetFloat("_GlitchColor", GlitchColor);
        TextureWriteMat.SetColor("_Col1", Themes.GetCurrentTheme().c1);
        TextureWriteMat.SetColor("_Col2", Themes.GetCurrentTheme().c2);
        TextureWriteMat.SetColor("_Col3", Themes.GetCurrentTheme().c3);
    }

    void Update () {
        if (ready)
        {
            UpdateParams();

            Audio.GetSpectrumData(spectrum, 0, FFTWindow.BlackmanHarris);

            TextureWriteMat.SetFloatArray("_Spectrum", spectrum);

            Graphics.Blit(null, RenderTex, TextureWriteMat);

            Wall.material.SetTexture("_MainTex", RenderTex);

            if(Wall2 != null)
            {
                Wall2.material.SetTexture("_MainTex", RenderTex);
            }

        }
    }
}