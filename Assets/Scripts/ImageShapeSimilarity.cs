using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using UnityEngine;

namespace Terry.MagicDuel
{
    public class ImageShapeSimilarity
    {
        private static ImageShapeSimilarity _instance;
        public static ImageShapeSimilarity Instance => _instance ?? (_instance = new ImageShapeSimilarity());

        Dictionary<SkillType, List<List<Vector2>>> skillList = new Dictionary<SkillType, List<List<Vector2>>>();

        public void Init()
        {
            string folderPath = @"Assets\Resources\standard"; // 文件夹路径
            string[] files = Directory.GetFiles(folderPath, "*.txt", SearchOption.AllDirectories);
            foreach (var file in files)
            {
                string fileName = Path.GetFileName(file);
                fileName = fileName.Substring(0, fileName.LastIndexOf('.'));
                if (Enum.TryParse<SkillType>(fileName, out SkillType skillType))
                {
                    Debug.Log("========fileName==========" + fileName);
                    List<List<Vector2>> loadPointsFromJson = LoadPointsFromJson(file);
                    skillList.Add(skillType, loadPointsFromJson);
                }
            }
        }

        // 对比用户输入路径与标准路径的相似度，返回 0~1
        public double Compare(List<List<Vector2>> target)
        {
            double maxSimilarity = 0;

            foreach (var key in skillList.Keys)
            {
                double similarity = CompareSkill(target, skillList[key]);
                Debug.Log($"====技能======={key}=======相似度======{similarity:F3}");
                if (similarity > maxSimilarity)
                    maxSimilarity = similarity;
            }

            return maxSimilarity;
        }

        // 多条笔画路径对比，忽略水平和垂直翻转
        private double CompareSkill(List<List<Vector2>> pathA, List<List<Vector2>> pathB)
        {
            List<double> distances = new List<double>();

            foreach (var strokeA in pathA)
            {
                double minDistance = double.MaxValue;
                var normA = NormalizePath(strokeA);

                // 生成 4 种翻转路径
                var flippedH = normA.Select(p => new Vector2(1f - p.x, p.y)).ToList();            // 左右翻转
                var flippedV = normA.Select(p => new Vector2(p.x, 1f - p.y)).ToList();            // 上下翻转
                var flippedHV = normA.Select(p => new Vector2(1f - p.x, 1f - p.y)).ToList();      // 左右+上下翻转

                foreach (var strokeB in pathB)
                {
                    var normB = NormalizePath(strokeB);

                    double d1 = DTWDistance(normA, normB);
                    double d2 = DTWDistance(flippedH, normB);
                    double d3 = DTWDistance(flippedV, normB);
                    double d4 = DTWDistance(flippedHV, normB);

                    double d = Math.Min(Math.Min(d1, d2), Math.Min(d3, d4));

                    if (d < minDistance) minDistance = d;
                }
                distances.Add(minDistance);
            }

            double avgDistance = distances.Average();
            double similarity = Math.Exp(-avgDistance * 5); // 调整指数可控敏感度
            return Math.Max(0, Math.Min(1, similarity));
        }

        // DTW 算法
        private double DTWDistance(List<Vector2> path1, List<Vector2> path2)
        {
            int n = path1.Count;
            int m = path2.Count;
            double[,] dtw = new double[n + 1, m + 1];

            for (int i = 0; i <= n; i++)
                for (int j = 0; j <= m; j++)
                    dtw[i, j] = double.PositiveInfinity;
            dtw[0, 0] = 0;

            for (int i = 1; i <= n; i++)
            {
                for (int j = 1; j <= m; j++)
                {
                    double cost = Vector2.Distance(path1[i - 1], path2[j - 1]);
                    dtw[i, j] = cost + Math.Min(Math.Min(dtw[i - 1, j], dtw[i, j - 1]), dtw[i - 1, j - 1]);
                }
            }
            return dtw[n, m] / (n + m); // 平均距离
        }

        // 坐标归一化到 0~1
        private List<Vector2> NormalizePath(List<Vector2> path)
        {
            if (path.Count == 0) return path;
            float minX = path.Min(p => p.x);
            float maxX = path.Max(p => p.x);
            float minY = path.Min(p => p.y);
            float maxY = path.Max(p => p.y);

            float width = maxX - minX;
            float height = maxY - minY;

            List<Vector2> norm = new List<Vector2>();
            foreach (var p in path)
            {
                float x = width > 0 ? (p.x - minX) / width : 0.5f;
                float y = height > 0 ? (p.y - minY) / height : 0.5f;
                norm.Add(new Vector2(x, y));
            }
            return norm;
        }

        // 从 JSON 加载坐标
        List<List<Vector2>> LoadPointsFromJson(string jsonPath)
        {
            var json = File.ReadAllText(jsonPath);
            var data = JsonConvert.DeserializeObject<List<List<Dictionary<string, double>>>>(json);
            return data.Select(
                group => group.Select(p => new Vector2((float)p["x"], (float)p["y"])).ToList()
            ).ToList();
        }
        
        public void drawStandardPic(SkillType skillType)
        {
            List<List<Vector2>> skill = skillList[skillType];
          
            for (int i = 0; i < skill.Count; i++)
            {
                DrawMananger.Instance.StartPaint();
                for (int j = 0; j < skill[i].Count; j++)
                {
                    DrawMananger.Instance.Paintting(new Vector3((skill[i][j].x-1f)*1.2f, skill[i][j].x*1.2f));
                }
                DrawMananger.Instance.EndPaint();
            }
        }
    }
}
