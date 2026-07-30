# obsidian-image-nvim

image.nvim 修改版，支持 Obsidian 风格的图片尺寸语法。

## 安装 (lazy.nvim)

```lua
{
    "Y-LarK/obsidian-image-nvim",
    name = "image.nvim",
    opts = {
        backend = "kitty",
        processor = "magick_cli",
        max_width_window_percentage = 90,
        max_height_window_percentage = 30,
    },
}
```

## 用法

```markdown
<!-- 默认 400px 宽 -->
![图片](path/to/image.png)

<!-- 指定宽度，高度自适应 -->
![图片|600](path/to/image.png)

<!-- 指定宽高 -->
![图片|600x400](path/to/image.png)
```

## 修改内容

基于 [3rd/image.nvim](https://github.com/3rd/image.nvim)，修改 3 个文件：

| 文件 | 改动 |
|------|------|
| `lua/image/integrations/markdown.lua` | 解析 alt 文本中的 `\|WIDTHxHEIGHT` |
| `lua/image/utils/document.lua` | 透传尺寸参数到图片渲染 |
| `lua/image/image.lua` | 缓存命中时更新几何尺寸 |
