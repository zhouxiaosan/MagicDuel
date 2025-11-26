using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using UnityEngine;
using Color = System.Drawing.Color;
using Graphics = System.Drawing.Graphics;

namespace Terry.MagicDuel
{
    public class ImageShapeSimilarity
    {
        private static ImageShapeSimilarity _instance;
        public static ImageShapeSimilarity Instance => _instance ?? (_instance = new ImageShapeSimilarity());

        Dictionary<SkillType, List<List<PointF>>> skillList = new Dictionary<SkillType, List<List<PointF>>>();
        private int bitmapSize = 256; // 栅格化分辨率，可调
         /// <summary>
        /// 初始化标准路径
        /// </summary>
        public void Init()
        {
            string folderPath = @"Assets\Resources\standard";
            string[] files = Directory.GetFiles(folderPath, "*.txt", SearchOption.AllDirectories);

            foreach (var file in files)
            {
                string fileName = Path.GetFileName(file);
                fileName = fileName.Substring(0, fileName.LastIndexOf('.'));
                if (Enum.TryParse<SkillType>(fileName, out SkillType skillType))
                {
                    Debug.Log("加载标准技能路径：" + fileName);
                    List<List<PointF>> loadPointsFromJson = LoadPointsFromJson(file);
                    skillList.Add(skillType, loadPointsFromJson);
                }
            }
        }

         
        public double Compare(List<List<PointF>> target)
        {
            double maxSimilarity = 0;

            foreach (var key in skillList.Keys)
            {
                double similarity = ComparePaths(target, skillList[key]) * 10 ;
                
                similarity = similarity > 1 ? 1 : similarity;
                
                Debug.Log($"技能 {key} 相似度: {similarity:F3}");
                if (similarity > maxSimilarity) maxSimilarity = similarity;
            }

            return maxSimilarity;
        }
        
        
        /// <summary>
        /// 将 stroke 合并并插值到固定点数
        /// </summary>
        private List<PointF> FlattenAndResample(List<List<PointF>> strokes, int targetPoints = 100)
        {
            var allPoints = strokes.SelectMany(NormalizePath).ToList();
            if (allPoints.Count < 2) return allPoints;

            var resampled = new List<PointF> { allPoints[0] };
            double totalLength = 0;
            for (int i = 1; i < allPoints.Count; i++)
            {
                totalLength += Distance(allPoints[i - 1], allPoints[i]);
            }
            double segmentLength = totalLength / (targetPoints - 1);
            double accumulated = 0;

            for (int i = 1; i < allPoints.Count; i++)
            {
                PointF p1 = allPoints[i - 1];
                PointF p2 = allPoints[i];
                double d = Distance(p1, p2);
                while (accumulated + d >= segmentLength)
                {
                    double t = (segmentLength - accumulated) / d;
                    float x = (float)(p1.X + t * (p2.X - p1.X));
                    float y = (float)(p1.Y + t * (p2.Y - p1.Y));
                    resampled.Add(new PointF(x, y));
                    p1 = new PointF(x, y);
                    d = Distance(p1, p2);
                    accumulated = 0;
                }
                accumulated += d;
            }
            while (resampled.Count < targetPoints) resampled.Add(allPoints.Last());
            return resampled;
        }
        
        /// <summary>
        /// 归一化到 [0,1] 范围
        /// </summary>
        private List<PointF> NormalizePath(List<PointF> path)
        {
            if (path.Count == 0) return path;
            float minX = path.Min(p => p.X);
            float maxX = path.Max(p => p.X);
            float minY = path.Min(p => p.Y);
            float maxY = path.Max(p => p.Y);
            float width = maxX - minX;
            float height = maxY - minY;
            float scale = Math.Max(width, height);
            return path.Select(p => new PointF(
                (p.X - minX) / scale,
                (p.Y - minY) / scale
            )).ToList();
        }

        private double Distance(PointF p1, PointF p2)
        {
            float dx = p1.X - p2.X;
            float dy = p1.Y - p2.Y;
            return Math.Sqrt(dx * dx + dy * dy);
        }

        /// <summary>
        /// 旋转路径
        /// </summary>
        private List<PointF> RotatePath(List<PointF> path, float angleDegrees)
        {
            double angle = angleDegrees * Math.PI / 180.0;
            var center = new PointF(path.Average(p => p.X), path.Average(p => p.Y));
            return path.Select(p =>
            {
                float dx = p.X - center.X;
                float dy = p.Y - center.Y;
                float xNew = (float)(dx * Math.Cos(angle) - dy * Math.Sin(angle)) + center.X;
                float yNew = (float)(dx * Math.Sin(angle) + dy * Math.Cos(angle)) + center.Y;
                return new PointF(xNew, yNew);
            }).ToList();
        }
        
        /// <summary>
        /// Hausdorff 距离
        /// </summary>
        private double HausdorffDistance(List<PointF> pathA, List<PointF> pathB)
        {
            double maxDistAB = pathA.Max(a => pathB.Min(b => Distance(a, b)));
            double maxDistBA = pathB.Max(b => pathA.Min(a => Distance(a, b)));
            return Math.Max(maxDistAB, maxDistBA);
        }

        /// <summary>
        /// DTW 距离
        /// </summary>
        private double DTWDistance(List<PointF> pathA, List<PointF> pathB)
        {
            int n = pathA.Count;
            int m = pathB.Count;
            double[,] dtw = new double[n, m];

            for (int i = 0; i < n; i++)
            for (int j = 0; j < m; j++)
                dtw[i, j] = double.PositiveInfinity;

            dtw[0, 0] = Distance(pathA[0], pathB[0]);

            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < m; j++)
                {
                    double cost = Distance(pathA[i], pathB[j]);
                    if (i > 0) dtw[i, j] = Math.Min(dtw[i, j], dtw[i - 1, j] + cost);
                    if (j > 0) dtw[i, j] = Math.Min(dtw[i, j], dtw[i, j - 1] + cost);
                    if (i > 0 && j > 0) dtw[i, j] = Math.Min(dtw[i, j], dtw[i - 1, j - 1] + cost);
                }
            }
            return dtw[n - 1, m - 1] / Math.Max(n, m);
        }
        /// <summary>
        /// 核心匹配函数：翻转 + 旋转 + DTW + Hausdorff
        /// </summary>
        public double ComparePaths(List<List<PointF>> target, List<List<PointF>> standard)
        {
            var targetPoints = FlattenAndResample(target);
            var standardPoints = FlattenAndResample(standard);

            float[] angles = { -15f, 0f, 15f };
            var flipOptions = new (bool flipX, bool flipY)[]
            {
                (false, false),
                (true, false),
                (false, true),
                (true, true)
            };

            double bestScore = 0;
            foreach (var flip in flipOptions)
            {
                var flipped = targetPoints.Select(p => new PointF(
                    flip.flipX ? 1 - p.X : p.X,
                    flip.flipY ? 1 - p.Y : p.Y
                )).ToList();

                foreach (var angle in angles)
                {
                    var rotated = RotatePath(flipped, angle);
                    double hausdorff = HausdorffDistance(rotated, standardPoints);
                    double dtw = DTWDistance(rotated, standardPoints);

                    // 融合相似度：距离越小，相似度越高
                    double similarity = Math.Exp(-5 * hausdorff) * Math.Exp(-5 * dtw);
                    if (similarity > bestScore) bestScore = similarity;
                }
            }
            return bestScore;
        }
        
        
        
        #region 核心算法（Bitmap + IoU）

        private double CompareShape(List<List<PointF>> pathA, List<List<PointF>> pathB)
        {
            using var bmpB = DrawBitmap(pathB, "standard");
            using var bmpA = DrawBitmap(pathA, "current");

            // 四翻转 + 小角度旋转
            var variants = new List<Bitmap>()
            {
                bmpA,
                FlipBitmap(bmpA, true, false),  // 水平翻转
                FlipBitmap(bmpA, false, true),  // 垂直翻转
                FlipBitmap(bmpA, true, true)    // 180度翻转
            };

            var rotatedVariants = new List<Bitmap>();
            foreach (var v in variants)
            {
                rotatedVariants.Add(v);
                rotatedVariants.Add(RotateBitmap(v, 15));
                rotatedVariants.Add(RotateBitmap(v, -15));
            }

            double maxSimilarity = 0;
            foreach (var variant in rotatedVariants)
            {
                double sim = IoUSimilarity(variant, bmpB);
                if (sim > maxSimilarity) maxSimilarity = sim;
                variant.Dispose(); // 释放旋转产生的 Bitmap
            }

            return maxSimilarity;
        }
        private Bitmap DrawBitmap(List<List<PointF>> strokes, string name)
        {
            var bmp = new Bitmap(bitmapSize, bitmapSize);
            using var g = Graphics.FromImage(bmp);
            g.Clear(Color.Black);

            var allPoints = strokes.SelectMany(s => s).ToList();
            float minX = allPoints.Min(p => p.X);
            float maxX = allPoints.Max(p => p.X);
            float minY = allPoints.Min(p => p.Y);
            float maxY = allPoints.Max(p => p.Y);

            float width = maxX - minX + 1e-3f;
            float height = maxY - minY + 1e-3f;

            using var pen = new Pen(Color.White, 4); // 粗线条
            foreach (var stroke in strokes)
            {
                if (stroke.Count < 2) continue;
                for (int i = 1; i < stroke.Count; i++)
                {
                    var p1 = new PointF((stroke[i - 1].X - minX) / width * bitmapSize,
                        (stroke[i - 1].Y - minY) / height * bitmapSize);
                    var p2 = new PointF((stroke[i].X - minX) / width * bitmapSize,
                        (stroke[i].Y - minY) / height * bitmapSize);
                    g.DrawLine(pen, p1, p2);
                }
            }

            string folderPath = @"Assets\Resources\standard";
            bmp.Save(Path.Combine(folderPath, name + ".png"), ImageFormat.Png);
            return bmp;
        }
        
        private Bitmap RotateBitmap(Bitmap bmp, float angle)
        {
            var rotated = new Bitmap(bmp.Width, bmp.Height);
            using var g = Graphics.FromImage(rotated);
            g.Clear(Color.Black);
            g.TranslateTransform(bmp.Width / 2f, bmp.Height / 2f);
            g.RotateTransform(angle);
            g.TranslateTransform(-bmp.Width / 2f, -bmp.Height / 2f);
            g.DrawImage(bmp, 0, 0);
            return rotated;
        }
        
        private Bitmap FlipBitmap(Bitmap bmp, bool horizontal, bool vertical)
        {
            var flipped = (Bitmap)bmp.Clone();
            if (horizontal && vertical)
                flipped.RotateFlip(RotateFlipType.Rotate180FlipNone);
            else if (horizontal)
                flipped.RotateFlip(RotateFlipType.RotateNoneFlipX);
            else if (vertical)
                flipped.RotateFlip(RotateFlipType.RotateNoneFlipY);
            return flipped;
        }

        private double IoUSimilarity(Bitmap bmp1, Bitmap bmp2)
        {
            if (bmp1.Width != bmp2.Width || bmp1.Height != bmp2.Height)
                throw new ArgumentException("Bitmap大小不一致");

            int intersection = 0, union = 0;

            var data1 = bmp1.LockBits(new Rectangle(0, 0, bmp1.Width, bmp1.Height),
                ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
            var data2 = bmp2.LockBits(new Rectangle(0, 0, bmp2.Width, bmp2.Height),
                ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);

            unsafe
            {
                byte* ptr1 = (byte*)data1.Scan0;
                byte* ptr2 = (byte*)data2.Scan0;
                int stride1 = data1.Stride;
                int stride2 = data2.Stride;

                for (int y = 0; y < bmp1.Height; y++)
                {
                    for (int x = 0; x < bmp1.Width; x++)
                    {
                        bool b1 = ptr1[y * stride1 + x * 3] > 127;
                        bool b2 = ptr2[y * stride2 + x * 3] > 127;
                        if (b1 || b2) union++;
                        if (b1 && b2) intersection++;
                    }
                }
            }

            bmp1.UnlockBits(data1);
            bmp2.UnlockBits(data2);

            return union == 0 ? 0 : (double)intersection / union;
        }

        #endregion
      
        #region JSON加载

        private List<List<PointF>> LoadPointsFromJson(string jsonPath)
        {
            var json = File.ReadAllText(jsonPath);
            var data = JsonConvert.DeserializeObject<List<List<Dictionary<string, double>>>>(json);
            return data.Select(
                group => group.Select(p => new PointF((float)p["x"], (float)p["y"])).ToList()
            ).ToList();
        }

        #endregion
        
        public void drawStandardPic(SkillType skillType)
        {
            List<List<PointF>> skill = skillList[skillType];
          
            for (int i = 0; i < skill.Count; i++)
            {
                DrawMananger.Instance.StartPaint();
                for (int j = 0; j < skill[i].Count; j++)
                {
                    DrawMananger.Instance.Paintting(new Vector3((skill[i][j].X-1f)*1.2f, skill[i][j].Y*1.2f));
                }
                DrawMananger.Instance.EndPaint();
            }
        }
    }
}
