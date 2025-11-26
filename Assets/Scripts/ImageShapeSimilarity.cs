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
                double similarity = CompareShape(target, skillList[key]);
                Debug.Log($"技能 {key} 相似度: {similarity:F3}");
                if (similarity > maxSimilarity) maxSimilarity = similarity;
            }

            return maxSimilarity;
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
