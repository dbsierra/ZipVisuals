using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Utilities
{
    public class ColorThemes : MonoBehaviour
    {

        public int CurrentTheme;
        public ColorTheme[] Themes;

        // Use this for initialization
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }

        public ColorTheme GetCurrentTheme()
        {
            return Themes[CurrentTheme];
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
}