local ok, image = pcall(require, "image")
if not ok then
    return
end

image.setup({
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
        markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = false,
            only_render_image_at_cursor = false,
            floating_windows = false,
            filetypes = { "markdown" },
        },
        html = {
            enabled = false,
        },
        css = {
            enabled = false,
        },
    },
    max_height_window_percentage = 50,
    window_overlap_clear_enabled = false,
    editor_only_render_when_focused = false,
    tmux_show_only_in_active_window = false,
    hijack_file_patterns = {
        "*.png",
        "*.jpg",
        "*.jpeg",
        "*.gif",
        "*.webp",
        "*.avif",
    },
})
