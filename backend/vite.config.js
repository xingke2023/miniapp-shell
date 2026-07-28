import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';
import postcssCascadeLayers from '@csstools/postcss-cascade-layers';
import postcssOklabFunction from '@csstools/postcss-oklab-function';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js', 'resources/css/filament/admin/theme.css'],
            refresh: true,
        }),
        tailwindcss(),
    ],
    // 兼容微信小程序 web-view 老内核（安卓 X5/XWeb < Chrome 99）：
    // oklab-function 给 oklch() 加 rgb 回退（preserve 保留 oklch 给现代浏览器），
    // cascade-layers 把 @layer 拍平成普通 CSS。两者都只加回退，不影响现代浏览器。
    css: {
        postcss: {
            plugins: [
                postcssOklabFunction({ preserve: false }),
                postcssCascadeLayers(),
            ],
        },
    },
});
