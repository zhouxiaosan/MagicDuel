using System;
using System.Collections;
using UnityEditor;
using UnityEngine;

namespace Terry.MagicDuel
{
    public class InputManager : MonoBehaviour
    {
        private InputManager _instance;
        
        public InputManager Instance => _instance ?? (_instance = new InputManager());
        
       public GameObject _lineParent;
       public Material [] _lineMaterial;
        
        /// <summary>
        /// 线段上一个点的位置
        /// </summary>
        private Vector3 lastDrawPoint;
        
        private void Awake()
        {
          DrawMananger.Instance.Init(_lineParent,_lineMaterial);
          ImageShapeSimilarity.Instance.Init();
         // StartCoroutine(delayDraDrawStandardPic());
        }
        
      
        IEnumerator delayDraDrawStandardPic()
        {
            yield return new WaitForSeconds(1f);
            ImageShapeSimilarity.Instance.drawStandardPic(SkillType.Tornado);
        }
        

        private void Update()
        {
            if (Input.GetMouseButtonDown(0))
            {
                DrawMananger.Instance.StartPaint();
            }

            if (Input.GetMouseButton(0))
            {
                Vector3 drawPoint = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y,1f));
                Debug.Log("=========手画======="+drawPoint);
                if (IsUseNewPoint(drawPoint, lastDrawPoint))
                {
                    lastDrawPoint = drawPoint;
                    DrawMananger.Instance.Paintting(drawPoint);
                   
                }
                else
                {
                    Debug.Log("=========舍弃======="+drawPoint);
                }
            }

            if (Input.GetMouseButtonUp(0))
            {
                DrawMananger.Instance.EndPaint();
            }

            if (Input.GetKeyDown(KeyCode.Z))
            {
                DrawMananger.Instance.BackLine();
            }

            if (Input.GetKeyDown(KeyCode.X))
            {
                DrawMananger.Instance.doClearLine();
            }
        }
        
        
        /// <summary>
        /// 比较两个点的距离是否相近，如果相近，返回False，反则true
        /// </summary>
        /// <returns></returns>
        public bool IsUseNewPoint(Vector3 newPoint, Vector3 oldPoint)
        {
            if (Math.Abs(newPoint.x - oldPoint.x) >= 0.003 ||
                Math.Abs(newPoint.y - oldPoint.y) >= 0.003)
            {
                return true;
            }

            return false;
        }
        
        
    }
}