$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$matrix=Get-Content -Raw (Join-Path $root 'baseline\game004_asset_matrix.json') -Encoding UTF8|ConvertFrom-Json
$out=Join-Path $root 'handoff\asset_production_v001\gptimage2_prompts';New-Item -ItemType Directory -Force $out|Out-Null
$style='GAME-004 approved art direction: warm ivory and sage-green habitat pod, rounded toy-like 3D animated-film render, soft diffuse lighting, gentle child-friendly forms, portrait mobile training-game composition, clear semantic silhouette, no text, no pseudo-UI, no watermark, no scary or sharp harmful details.'
$template=@{
 objects=@{
  L1='3 by 2 contact sheet, six separate isolated runtime object assets on warm ivory background with generous spacing: {items}. Each object centered in its own equal cell, front three-quarter view, soft shadow, consistent scale, no overlap, no labels, no borders.'
  L2='3 by 2 contact sheet, six separate isolated objects, same family and material as reference habitat assets, distinguished only by the frozen attribute ({attribute}): {items}. Soft studio light, warm ivory background, no overlap, no labels.'
  L3='3 by 2 contact sheet, six separate isolated objects showing novel instances and alternative viewpoints/materials of the same habitat family: {items}. Keep identical material language, no overlap, no labels.'
  L4='3 by 2 contact sheet, six separate isolated objects where the rule-relevant feature is clear and one irrelevant feature varies freely (e.g. color vs size, shape vs texture): {items}. Same material language, no overlap, no labels.'
  L5='L5 authorized photo container: a warm ivory habitat frame that will hold a real child photo later, placeholder silhouette only, no real face, no text: {items}. Same material language.'
 }
 regions=@{
  L1='3 by 2 contact sheet, six separate isolated rounded diorama habitat region tiles on warm ivory background: {items}. Front three-quarter view, same material language as the habitat shell, low visual density, no overlap, no labels.'
  L2='3 by 2 contact sheet, six habitat region tiles, each shows a clear single-attribute distinction (size/color/function): {items}. Same material language, no overlap, no labels.'
  L3='3 by 2 contact sheet, six habitat region tiles showing rule-switching and hierarchical classification layout: {items}. Same material language, no overlap, no labels.'
  L4='3 by 2 contact sheet, six habitat region tiles showing 3-4 connected regions with water flow between them: {items}. Same material language, no overlap, no labels.'
 }
 outcomes=@{
  L1='3 by 2 contact sheet, six compact natural ecosystem result state icons on warm ivory background: {items}. Tiny sprout, lamp glow, leaf unfolding, stable mossy rock, water stream, workbench indicator. Same material language, no fireworks, no particles, no labels.'
  L2='3 by 2 contact sheet, six natural outcome states showing controlled attribute change after correct placement: {items}. Same material language, no labels.'
  L3='3 by 2 contact sheet, six natural outcome states for rule-switching rounds: {items}. Same material language, no labels.'
  L4='3 by 2 contact sheet, six natural outcome states connecting multiple systems after correct placement: {items}. Same material language, no labels.'
 }
}
$template|ConvertTo-Json -Depth 8|Set-Content (Join-Path $out 'gptimage2_prompt_templates.json') -Encoding UTF8
@('# GAME-004 GPT Image 2 PROMPT TEMPLATES V1','','Model: openai/gpt-image-2/text-to-image, $0.009 per image, png, high quality.','','Rules:','1. {items} fills only frozen round object/region/outcome semantics; never change frozen_content.','2. Always prefix with the unified style prompt.','3. Regions and outcomes reuse the same contact sheet to reduce image count.','4. Every output goes to candidates first; visual review required before processed/approved.','5. No image is auto-approved.')|Set-Content (Join-Path $out 'README.md') -Encoding UTF8
Write-Host 'GPTIMAGE2_TEMPLATES_PASS groups='+($template.Keys.Count)
