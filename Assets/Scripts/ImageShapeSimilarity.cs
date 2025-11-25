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


        public void Init()
        { 
            string folderPath =@"Assets\Resources\standard"; // 文件夹路径
            string[] files = Directory.GetFiles(folderPath, "*.txt", SearchOption.AllDirectories);
            foreach (var file in files)
            {
                
                // 获取文件名（包含扩展名）
                string fileName = Path.GetFileName(file);
                fileName = fileName.Substring(0, fileName.LastIndexOf('.'));
                if(Enum.TryParse<SkillType>(fileName, out SkillType skillType)) 
                {
                    Debug.Log("========fileName=========="+fileName);
                    List<List<PointF>> loadPointsFromJson = LoadPointsFromJson(file);
                    skillList.Add(skillType,loadPointsFromJson);
                }
            }
            
        }
        
        
        public double Compare(List<List<PointF>> target, int imageSize = 256)
        {
            double similarity = 0;

            foreach (var key in skillList.Keys)
            {
                using var imgA = DrawStrokes(skillList[key], imageSize);
                using var imgB = DrawStrokes(target, imageSize);
                double va = CalculateSSIM(imgA, imgB);
                Debug.Log("====技能======="+key+"=======相似度======"+va);
                if (va > similarity)
                {
                    similarity = va;
                } 
            }
            
           


            return similarity;
        }

        // 1️⃣ 把笔画坐标集画到Bitmap上
        Bitmap DrawStrokes(List<List<PointF>> strokes, int size)
        {
            var bmp = new Bitmap(size, size);
            using var g = Graphics.FromImage(bmp);
            g.Clear(Color.Black);

            // 把所有坐标平移/缩放到画布内
            var allPoints = strokes.SelectMany(s => s).ToList();
            float minX = allPoints.Min(p => p.X), maxX = allPoints.Max(p => p.X);
            float minY = allPoints.Min(p => p.Y), maxY = allPoints.Max(p => p.Y);

            float scale = Math.Min(size / (maxX - minX + 1e-3f), size / (maxY - minY + 1e-3f)) * 0.9f;
            float offsetX = size / 2f - scale * (minX + maxX) / 2f;
            float offsetY = size / 2f - scale * (minY + maxY) / 2f;

            using var pen = new Pen(Color.White, 2);
            foreach (var stroke in strokes)
            {
                if (stroke.Count < 2) continue;
                for (int i = 1; i < stroke.Count; i++)
                {
                    var p1 = new PointF(stroke[i - 1].X * scale + offsetX, stroke[i - 1].Y * scale + offsetY);
                    var p2 = new PointF(stroke[i].X * scale + offsetX, stroke[i].Y * scale + offsetY);
                    g.DrawLine(pen, p1, p2);
                }
            }
            string folderPath =@"Assets\Resources\standard";
            bmp.Save(folderPath+"\\sim.png",ImageFormat.Png);
            return bmp;
        }

        // 2️⃣ 简化版 SSIM（结构相似性）
        double CalculateSSIM(Bitmap imgA, Bitmap imgB)
        {
            if (imgA.Width != imgB.Width || imgA.Height != imgB.Height)
                throw new ArgumentException("图像大小不一致");

            double meanA = 0, meanB = 0;
            int w = imgA.Width, h = imgA.Height;

            // 灰度提取
            double[,] aVals = new double[w, h];
            double[,] bVals = new double[w, h];

            for (int x = 0; x < w; x++)
            {
                for (int y = 0; y < h; y++)
                {
                    var ca = imgA.GetPixel(x, y);
                    var cb = imgB.GetPixel(x, y);
                    double va = ca.R / 255.0;
                    double vb = cb.R / 255.0;
                    aVals[x, y] = va;
                    bVals[x, y] = vb;
                    meanA += va;
                    meanB += vb;
                }
            }

            int n = w * h;
            meanA /= n;
            meanB /= n;

            double varA = 0, varB = 0, covAB = 0;
            for (int x = 0; x < w; x++)
            {
                for (int y = 0; y < h; y++)
                {
                    varA += Math.Pow(aVals[x, y] - meanA, 2);
                    varB += Math.Pow(bVals[x, y] - meanB, 2);
                    covAB += (aVals[x, y] - meanA) * (bVals[x, y] - meanB);
                }
            }

            varA /= n - 1;
            varB /= n - 1;
            covAB /= n - 1;

            double c1 = 0.01 * 0.01;
            double c2 = 0.03 * 0.03;

            double ssim = (2 * meanA * meanB + c1) * (2 * covAB + c2) /
                          ((meanA * meanA + meanB * meanB + c1) * (varA + varB + c2));

            return Math.Max(0, Math.Min(1, ssim));
        }
        static List<List<PointF>> LoadPointsFromJson(string jsonPath)
        {
            var json = File.ReadAllText(jsonPath);
            var data = JsonConvert.DeserializeObject<List<List<Dictionary<string, double>>>>(json);
            return data.Select(
                group => group.Select(p => new PointF((float)p["x"], (float)p["y"])).ToList()
            ).ToList();
        }

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

