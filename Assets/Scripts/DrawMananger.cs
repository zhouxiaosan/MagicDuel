
using System;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;

namespace Terry.MagicDuel
{
    public class DrawMananger : MonoBehaviour
    {
        private static DrawMananger _instance;
        public static DrawMananger Instance => _instance ?? (_instance = new DrawMananger());
        
        // 当前线段对象
        public GameObject currLineObj;
        // 线段集合
        public List<GameObject> lineObjs;
        
        public GameObject lineParent;
        /// <summary>
        /// 线段对象的管理池
        /// </summary>
        public List<GameObject> linePool;
        /// <summary>
        /// 线段使用的材质
        /// </summary>
        private Material[] lineMateria;
        
        private float lineWidth; // 线的粗细

        private List<Vector2> currPointList;
        /// <summary>
        /// 整图的坐标点
        /// </summary>
        public List<List<Vector2>> _picPoints = new  List<List<Vector2>>();

        public void Init(GameObject _lineParent,Material[] _lineMateria)
        {
            lineObjs = new List<GameObject>();
            this.lineWidth = 0.1f;
            lineParent = _lineParent;
            lineMateria = _lineMateria;
            //初始化若干个线段对象，避免重复创建销毁
            linePool = new List<GameObject>();
            for (int i = 0; i < 10; i++)
            {
                linePool.Add(createLineObj());
            }
        }
        
        /// <summary>
        /// 初始化N个线段对象，供复用
        /// </summary>
        /// <returns></returns>
        private GameObject createLineObj()
        {
            GameObject obj = new GameObject();
            obj.name = "Line";
            obj.transform.SetParent(lineParent.transform);
            LineRenderer lineRenderer = obj.AddComponent<LineRenderer>();

            lineRenderer.startWidth = lineWidth;
            lineRenderer.endWidth = lineWidth;
            lineRenderer.sortingOrder = 1;
            lineRenderer.positionCount = 0;
           
            return obj;
        }
        
        /// <summary>
        /// 获取一个线段对象
        /// </summary>
        /// <returns></returns>
        private GameObject getALineObj()
        {
            GameObject result = null;
            if (linePool == null)
            {
                return null;
            }

            foreach (GameObject obj in linePool)
            {
                if (obj.GetComponent<LineRenderer>().positionCount == 0)
                {
                    result = obj;
                    break;
                }
            }

            // 池子里的对象用完了。就创建新的对象，丢进池子里
            if (result == null)
            {
                result = createLineObj();
                linePool.Add(result);
            }

            return result;
        }     
        
        /// <summary>
        /// 开始一个线段
        /// </summary>
        public void StartPaint()
        {
            currLineObj = getALineObj();
            if (currLineObj != null)
            {
                LineRenderer lineRenderer = currLineObj.GetComponent<LineRenderer>();
                lineRenderer.materials = lineMateria;
                lineObjs.Add(currLineObj);
                currPointList = new List<Vector2>();
            }
        }

        /// <summary>
        /// 持续画线段
        /// </summary>
        public void Paintting(Vector3 position)
        {
            if (currLineObj == null)
            {
                return;
            }

            LineRenderer lineRenderer = currLineObj.transform.GetComponent<LineRenderer>();
            lineRenderer.positionCount++;
            lineRenderer.SetPosition(lineRenderer.positionCount - 1, position);
            currPointList.Add(new Vector2(position.x, position.y));
        }

        public void EndPaint()
        {
            _picPoints.Add(currPointList);

            double sm = ImageShapeSimilarity.Instance.Compare(_picPoints);
          
            Debug.Log("=========相似度============"+sm);
        }

        /// <summary>
        /// 回退线条
        /// </summary>
        public void BackLine()
        {
            if (lineObjs.Count > 0)
            {
                lineObjs[lineObjs.Count - 1].GetComponent<LineRenderer>().positionCount = 0;
                lineObjs[lineObjs.Count - 1].GetComponent<LineRenderer>().SetPositions(new Vector3[] { });


                lineObjs.Remove(lineObjs[lineObjs.Count - 1]);
                _picPoints.RemoveAt(_picPoints.Count - 1);
            }
        }
        /// <summary>
        /// 清空所有线段
        /// </summary>
        public void doClearLine()
        {
            lineObjs.Clear();
            _picPoints.Clear();
            foreach (var lingObj in linePool)
            {
                lingObj.GetComponent<LineRenderer>().positionCount = 0;
                lingObj.GetComponent<LineRenderer>().SetPositions(new Vector3[] { });
            }
        }

        
        
    }

}
