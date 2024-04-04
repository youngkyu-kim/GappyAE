for file in gappyAE_diffusion*.ipynb; do
  sed -i '' 's|./diffusion_data|../__data/ex16_diffusion|g' "$file"
  sed -i '' 's|./diffusion_model|../__model/ex16_diffusion|g' "$file"
  sed -i '' 's|./diffusion_result|../__result/ex16_diffusion|g' "$file"
  sed -i '' 's|./diffusion_temp|../__temp/ex16_diffusion|g' "$file"
done

for file in gappyPOD_diffusion*.ipynb; do
  sed -i '' 's|./diffusion_data|../__data/ex16_diffusion|g' "$file"
  sed -i '' 's|./diffusion_model|../__model/ex16_diffusion|g' "$file"
  sed -i '' 's|./diffusion_result|../__result/ex16_diffusion|g' "$file"
  sed -i '' 's|./diffusion_temp|../__temp/ex16_diffusion|g' "$file"
done