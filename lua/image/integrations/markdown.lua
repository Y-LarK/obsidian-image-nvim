local document = require("image/utils/document")

return document.create_document_integration({
  name = "markdown",
  debug = true,
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = false,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "markdown", "vimwiki" },
  },
  query_buffer_images = function(buffer)
    local buf = buffer or vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(buf, "markdown")
    parser:parse(true)
    local inline_lang = "markdown_inline"
    local inlines = parser:children()[inline_lang]

    local query_with_alt = vim.treesitter.query.parse(inline_lang,
      "(image (image_description) @alt (link_destination) @url) @image")
    local shortcut_query =
      vim.treesitter.query.parse(inline_lang, "(image (image_description (shortcut_link (link_text) @url))) @image")

    if not inlines then return {} end

    local images = {}
    local function get_inline_images(tree)
      local root = tree:root()
      local current_image = nil

      for _, query in ipairs({ query_with_alt, shortcut_query }) do
        ---@diagnostic disable-next-line: missing-parameter
        for id, node in query:iter_captures(root, buf) do
          local key = query.captures[id]
          local value = vim.treesitter.get_node_text(node, buf)

          if key == "image" then
            local start_row, start_col, end_row, end_col = node:range()
            current_image = {
              node = node,
              range = {
                start_row = start_row,
                start_col = start_col,
                end_row = end_row,
                end_col = end_col,
              },
            }
          elseif current_image and key == "alt" then
            local pw, ph = value:match("|(%d+)x(%d+)")
            if not pw then pw = value:match("|(%d+)") end
            if pw then
              current_image.width = tonumber(pw) -- 像素值，document.lua 会 ÷cell_width 转格数
              if ph then current_image.height = tonumber(ph) end
            else
              current_image.width = 400 -- 默认 400px
            end
          elseif current_image and key == "url" then
            current_image.url = value
            table.insert(images, current_image)
            current_image = nil
          end
        end
      end
    end

    inlines:for_each_tree(get_inline_images)
    return images
  end,
})
